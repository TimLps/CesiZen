<?php

use Illuminate\Support\Facades\Route;

Route::get('/', fn () => response()->json([
    'service' => 'CESIZen API',
    'docs'    => '/api/documentation',
    'health'  => '/api/health',
]));
