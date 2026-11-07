<?php

namespace VK7\Wholesale\Http\Controllers\Api\Admin;

use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;
use VK7\Wholesale\Http\Controllers\Api\Controller;
use VK7\Wholesale\Models\SupportTicket;
use VK7\Wholesale\Services\ActivityRecorder;

class SupportDeskController extends Controller
{
    /**
     * Create a new controller instance.
     */
    public function __construct(protected ActivityRecorder $activity) {}

    /**
     * Every ticket, newest first, with open and urgent work counted.
     */
    public function index(): JsonResponse
    {
        $tickets = SupportTicket::query()->latest('id')->get();

        return response()->json([
            'data' => $tickets->map->forStaff()->values(),
            'meta' => [
                'open' => $tickets->where('status', 'open')->count(),
                'in_progress' => $tickets->where('status', 'in_progress')->count(),
                'overdue' => $tickets->filter(fn ($ticket) => $ticket->forStaff()['overdue'])->count(),
            ],
        ]);
    }

    /**
     * One ticket.
     */
    public function show(int $id): JsonResponse
    {
        $ticket = SupportTicket::find($id);

        return $ticket
            ? response()->json(['data' => $ticket->forStaff()])
            : $this->fail(trans('Ticket not found.'), 'NOT_FOUND', 404);
    }

    /**
     * Change a ticket's status, priority or owner, reply to the customer, or add a private note.
     */
    public function update(Request $request, int $id): JsonResponse
    {
        $data = $request->validate([
            'status' => ['required', Rule::in(SupportTicket::STATUSES)],
            'priority' => ['required', Rule::in(SupportTicket::PRIORITIES)],
            'assigned_to' => ['nullable', 'string', 'max:255'],
            'reply' => ['nullable', 'string', 'max:3000'],
            'note' => ['nullable', 'string', 'max:1000'],
        ]);

        $ticket = SupportTicket::find($id);

        if (! $ticket) {
            return $this->fail(trans('Ticket not found.'), 'NOT_FOUND', 404);
        }

        $staff = $request->attributes->get('staff')->name;
        $notes = $ticket->notes ?? [];

        if (! empty($data['note'])) {
            $notes[] = ['at' => now()->toIso8601String(), 'by' => $staff, 'text' => $data['note']];
        }

        $changes = [
            'status' => $data['status'],
            'priority' => $data['priority'],
            'assigned_to' => ($data['assigned_to'] ?? null) ?: ($ticket->assigned_to ?: $staff),
            'notes' => $notes,
            'resolved_at' => in_array($data['status'], ['resolved', 'closed']) ? ($ticket->resolved_at ?? now()) : null,
        ];

        if (
            ! empty($data['reply'])
            && $data['reply'] !== $ticket->reply
        ) {
            $changes['reply'] = $data['reply'];
            $changes['replied_at'] = now();
        }

        $ticket->update($changes);

        $this->activity->record($staff, 'Updated support ticket', $ticket->number(), 'Status: '.$data['status']);

        return response()->json(['data' => $ticket->fresh()->forStaff()]);
    }
}
