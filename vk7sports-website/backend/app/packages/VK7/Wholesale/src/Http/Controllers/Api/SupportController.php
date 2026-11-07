<?php

namespace VK7\Wholesale\Http\Controllers\Api;

use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;
use VK7\Wholesale\Models\SupportTicket;
use VK7\Wholesale\Services\ActivityRecorder;

class SupportController extends Controller
{
    /**
     * Hours within which the support team promises to make contact.
     */
    public const CONTACT_WITHIN_HOURS = 24;

    /**
     * Create a new controller instance.
     */
    public function __construct(protected ActivityRecorder $activity) {}

    /**
     * Save a complaint or problem from anyone; a signed-in retailer's ticket is linked to their account.
     */
    public function store(Request $request): JsonResponse
    {
        $customer = $this->customer();

        if (
            $customer
            && ! $request->filled('email')
        ) {
            $request->merge(['email' => $customer->email]);
        }

        $data = $request->validate([
            'name' => ['required', 'string', 'max:255'],
            'business_name' => ['nullable', 'string', 'max:255'],
            'email' => ['nullable', 'required_without:phone', 'email', 'max:255'],
            'phone' => ['nullable', 'required_without:email', 'regex:/^[6-9]\d{9}$/'],
            'preferred_contact' => ['nullable', Rule::in(SupportTicket::CONTACT_BY)],
            'category' => ['required', Rule::in(SupportTicket::CATEGORIES)],
            'order_number' => ['nullable', 'string', 'max:40'],
            'subject' => ['required', 'string', 'max:150'],
            'message' => ['required', 'string', 'min:10', 'max:3000'],
        ], [
            'name.required' => trans('Please enter your name.'),
            'email.required_without' => trans('Give a mobile number or an email so we can contact you.'),
            'phone.required_without' => trans('Give a mobile number or an email so we can contact you.'),
            'phone.regex' => trans('Enter a 10-digit Indian mobile number.'),
            'category.required' => trans('Choose what the problem is about.'),
            'subject.required' => trans('Give the problem a short title.'),
            'message.required' => trans('Please describe the problem.'),
            'message.min' => trans('Please tell us a little more, at least 10 characters.'),
        ]);

        $ticket = SupportTicket::create(array_merge($data, [
            'customer_id' => $customer?->id,
            'preferred_contact' => $data['preferred_contact'] ?? (empty($data['phone']) ? 'email' : 'phone'),
            'priority' => in_array($data['category'], ['payment', 'delivery']) ? 'high' : 'normal',
            'status' => 'open',
            'contact_by' => now()->addHours(self::CONTACT_WITHIN_HOURS),
        ]));

        $this->activity->record($data['name'], 'Raised support ticket', $ticket->number(), $data['subject']);

        return response()->json(['data' => array_merge($ticket->forCustomer(), [
            'contact_within_hours' => self::CONTACT_WITHIN_HOURS,
            'preferred_contact' => $ticket->preferred_contact,
        ])], 201);
    }

    /**
     * Tickets raised by the signed-in retailer, by account or by their email.
     */
    public function mine(): JsonResponse
    {
        $customer = $this->customer();

        $tickets = SupportTicket::query()
            ->where(fn ($query) => $query->where('customer_id', $customer->id)->orWhere('email', $customer->email))
            ->latest('id')
            ->get();

        return response()->json(['data' => $tickets->map->forCustomer()->values()]);
    }

    /**
     * Let anyone check a ticket with its reference and the email or mobile used to raise it.
     */
    public function check(Request $request): JsonResponse
    {
        $data = $request->validate([
            'number' => ['required', 'string', 'max:20'],
            'contact' => ['required', 'string', 'max:255'],
        ]);

        $id = SupportTicket::idFromNumber($data['number']);
        $ticket = $id ? SupportTicket::find($id) : null;
        $contact = strtolower(trim($data['contact']));

        if (
            ! $ticket
            || ! in_array($contact, array_filter([strtolower((string) $ticket->email), (string) $ticket->phone]), true)
        ) {
            return $this->fail(trans('We could not find a ticket with those details.'), 'NOT_FOUND', 404);
        }

        return response()->json(['data' => $ticket->forCustomer()]);
    }
}
