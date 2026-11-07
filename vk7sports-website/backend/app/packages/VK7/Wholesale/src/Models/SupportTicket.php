<?php

namespace VK7\Wholesale\Models;

use Illuminate\Database\Eloquent\Model;

class SupportTicket extends Model
{
    /**
     * Kinds of problem a customer can report.
     */
    public const CATEGORIES = ['order', 'payment', 'delivery', 'product', 'account', 'website', 'other'];

    /**
     * Where a ticket is in the support process.
     */
    public const STATUSES = ['open', 'in_progress', 'resolved', 'closed'];

    /**
     * How urgent staff judge a ticket to be.
     */
    public const PRIORITIES = ['low', 'normal', 'high', 'urgent'];

    /**
     * How the customer would like to be contacted.
     */
    public const CONTACT_BY = ['phone', 'whatsapp', 'email'];

    /**
     * The table the model maps to.
     *
     * @var string
     */
    protected $table = 'vk7_support_tickets';

    /**
     * The attributes that are mass assignable.
     *
     * @var array
     */
    protected $fillable = [
        'customer_id',
        'name',
        'business_name',
        'email',
        'phone',
        'preferred_contact',
        'category',
        'order_number',
        'subject',
        'message',
        'priority',
        'status',
        'assigned_to',
        'reply',
        'replied_at',
        'notes',
        'contact_by',
        'resolved_at',
    ];

    /**
     * The attributes that should be cast.
     *
     * @var array
     */
    protected $casts = [
        'notes' => 'array',
        'replied_at' => 'datetime',
        'contact_by' => 'datetime',
        'resolved_at' => 'datetime',
    ];

    /**
     * The reference shown to customers and staff.
     */
    public function number(): string
    {
        return 'SUP-'.str_pad((string) $this->id, 5, '0', STR_PAD_LEFT);
    }

    /**
     * Read a reference such as SUP-00012 back into an id.
     */
    public static function idFromNumber(string $number): ?int
    {
        return preg_match('/^SUP-?(\d{1,9})$/i', trim($number), $m) ? (int) $m[1] : null;
    }

    /**
     * What the customer may see about their ticket.
     */
    public function forCustomer(): array
    {
        return [
            'id' => $this->id,
            'number' => $this->number(),
            'category' => $this->category,
            'order_number' => $this->order_number,
            'subject' => $this->subject,
            'message' => $this->message,
            'status' => $this->status,
            'reply' => $this->reply,
            'replied_at' => $this->replied_at,
            'contact_by' => $this->contact_by,
            'created_at' => $this->created_at,
            'updated_at' => $this->updated_at,
        ];
    }

    /**
     * Everything staff work with.
     */
    public function forStaff(): array
    {
        return array_merge($this->forCustomer(), [
            'customer_id' => $this->customer_id,
            'name' => $this->name,
            'business_name' => $this->business_name,
            'email' => $this->email,
            'phone' => $this->phone,
            'preferred_contact' => $this->preferred_contact,
            'priority' => $this->priority,
            'assigned_to' => $this->assigned_to,
            'notes' => $this->notes ?? [],
            'resolved_at' => $this->resolved_at,
            'overdue' => in_array($this->status, ['open', 'in_progress']) && $this->contact_by?->isPast(),
        ]);
    }
}
