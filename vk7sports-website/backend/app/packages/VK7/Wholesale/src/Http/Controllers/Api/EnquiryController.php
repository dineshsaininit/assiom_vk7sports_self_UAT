<?php

namespace VK7\Wholesale\Http\Controllers\Api;

use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;
use VK7\Wholesale\Repositories\EnquiryRepository;

class EnquiryController extends Controller
{
    /**
     * Kinds of enquiry the public form can send.
     */
    public const TYPES = ['general', 'bulk', 'custom', 'school_club_team', 'dealer'];

    /**
     * Create a new controller instance.
     */
    public function __construct(protected EnquiryRepository $enquiryRepository) {}

    /**
     * Save an enquiry for sales to follow up.
     */
    public function store(Request $request): JsonResponse
    {
        $data = $request->validate([
            'type' => ['nullable', Rule::in(self::TYPES)],
            'name' => ['required', 'string', 'max:255'],
            'business_name' => ['nullable', 'string', 'max:255'],
            'email' => ['required', 'email', 'max:255'],
            'phone' => ['nullable', 'string', 'max:30'],
            'city' => ['nullable', 'string', 'max:100'],
            'quantity' => ['nullable', 'integer', 'min:1', 'max:1000000'],
            'product_id' => ['nullable', 'integer', 'exists:products,id'],
            'message' => ['required', 'string', 'max:2000'],
        ]);

        $enquiry = $this->enquiryRepository->create(array_merge(['type' => 'general'], $data));

        return response()->json(['data' => [
            'id' => $enquiry->id,
            'status' => 'new',
        ]], 201);
    }
}
