<?php

namespace VK7\Wholesale;

use Webkul\Sales\Contracts\Sequencer as SequencerContract;
use Webkul\Sales\Generators\OrderSequencer;

class OrderNumberSequencer extends OrderSequencer implements SequencerContract
{
    /**
     * Claim the next order number from a single locked counter row, so concurrent checkouts never share one.
     * The counter never falls behind existing orders, so a restored database cannot repeat a number.
     *
     * @return int
     */
    public function getLastId()
    {
        return app(Sequence::class)->next('order', 'orders') - 1;
    }

    /**
     * Keep this sequencer in charge even when a generator class is configured.
     */
    public function resolveGeneratorClass()
    {
        return $this->generate();
    }
}
