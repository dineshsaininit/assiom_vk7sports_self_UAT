<?php

use Illuminate\Support\Facades\Route;
use VK7\Wholesale\Http\Controllers\Admin\EnquiryController;

Route::group([
    'middleware' => ['web', 'admin'],
    'prefix' => config('app.admin_url').'/vk7/enquiries',
    'as' => 'admin.vk7.enquiries.',
], function () {
    Route::get('', [EnquiryController::class, 'index'])->name('index');

    Route::put('{id}', [EnquiryController::class, 'update'])->name('update');
});
