<?php

namespace VK7\Wholesale\Http\Controllers\Admin;

use Illuminate\Http\Request;
use Illuminate\Routing\Controller;
use Illuminate\Validation\Rule;
use VK7\Wholesale\Repositories\EnquiryRepository;

class EnquiryController extends Controller
{
    /**
     * Follow-up states sales can set.
     */
    public const STATUSES = ['new', 'contacted', 'converted', 'closed'];

    /**
     * Create a new controller instance.
     */
    public function __construct(protected EnquiryRepository $enquiryRepository) {}

    /**
     * Show the enquiry queue, newest first.
     */
    public function index()
    {
        return view('vk7::admin.enquiries.index', [
            'enquiries' => $this->enquiryRepository->orderBy('id', 'desc')->paginate(20),
            'statuses' => self::STATUSES,
        ]);
    }

    /**
     * Update the follow-up state of an enquiry.
     */
    public function update(Request $request, int $id)
    {
        $data = $request->validate(['status' => ['required', Rule::in(self::STATUSES)]]);

        $this->enquiryRepository->update($data, $id);

        return back();
    }
}
