<?php

namespace VK7\Wholesale;

use Illuminate\Support\Facades\DB;
use Webkul\Sales\Contracts\Sequencer as SequencerContract;
use Webkul\Sales\Generators\OrderSequencer;

class OrderNumberSequencer extends OrderSequencer implements SequencerContract
{
    /**
     * Claim the next order number from a single locked counter row, so concurrent checkouts never share one.
     * ponytail: one row serialises numbering for the whole store; fine for wholesale volume.
     *
     * @return int
     */
    public function getLastId()
    {
        $sequence = DB::table('vk7_sequences')->where('name', 'order');

        $last = (int) $sequence->lockForUpdate()->value('value');

        $sequence->update(['value' => $last + 1]);

        return $last;
    }
}
