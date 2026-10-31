<x-admin::layouts>
    <x-slot:title>
        Enquiries
    </x-slot>

    <p class="mb-4 text-xl font-bold text-gray-800 dark:text-white">
        Enquiries
    </p>

    <div class="box-shadow overflow-x-auto rounded bg-white p-4 dark:bg-gray-900 dark:text-gray-300">
        <table class="w-full text-left text-sm">
            <thead>
                <tr>
                    <th class="p-2">#</th>
                    <th class="p-2">Type</th>
                    <th class="p-2">Contact</th>
                    <th class="p-2">Business</th>
                    <th class="p-2">Qty</th>
                    <th class="p-2">Message</th>
                    <th class="p-2">Received</th>
                    <th class="p-2">Status</th>
                </tr>
            </thead>

            <tbody>
                @forelse ($enquiries as $enquiry)
                    <tr class="border-t dark:border-gray-800">
                        <td class="p-2">{{ $enquiry->id }}</td>
                        <td class="p-2">{{ $enquiry->type }}</td>
                        <td class="p-2">{{ $enquiry->name }}<br>{{ $enquiry->email }}<br>{{ $enquiry->phone }}</td>
                        <td class="p-2">{{ $enquiry->business_name }}<br>{{ $enquiry->city }}</td>
                        <td class="p-2">{{ $enquiry->quantity }}</td>
                        <td class="p-2">{{ $enquiry->message }}</td>
                        <td class="p-2">{{ $enquiry->created_at }}</td>
                        <td class="p-2">
                            <form
                                method="POST"
                                action="{{ route('admin.vk7.enquiries.update', $enquiry->id) }}"
                            >
                                @csrf
                                @method('PUT')

                                <select
                                    name="status"
                                    onchange="this.form.submit()"
                                    class="rounded border p-1 dark:bg-gray-800"
                                >
                                    @foreach ($statuses as $status)
                                        <option
                                            value="{{ $status }}"
                                            @selected($enquiry->status === $status)
                                        >
                                            {{ $status }}
                                        </option>
                                    @endforeach
                                </select>
                            </form>
                        </td>
                    </tr>
                @empty
                    <tr>
                        <td
                            colspan="8"
                            class="p-4 text-center"
                        >
                            No enquiries yet.
                        </td>
                    </tr>
                @endforelse
            </tbody>
        </table>

        <div class="mt-4">
            {{ $enquiries->links() }}
        </div>
    </div>
</x-admin::layouts>
