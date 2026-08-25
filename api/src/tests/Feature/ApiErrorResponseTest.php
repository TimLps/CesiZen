<?php

namespace Tests\Feature;

use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class ApiErrorResponseTest extends TestCase
{
    use RefreshDatabase;

    /**
     * Une requête non authentifiée doit être refusée par un 401 JSON, y
     * compris lorsque le client n'annonce pas Accept: application/json —
     * cas typique d'un appel depuis un client HTTP ou un navigateur.
     */
    public function test_unauthenticated_api_request_returns_401_without_accept_header(): void
    {
        $response = $this->get('/api/journal', ['Accept' => 'text/html']);

        $response->assertStatus(401);
        $response->assertJson(['message' => 'Unauthenticated.']);
    }

    public function test_unauthenticated_admin_request_returns_401_without_accept_header(): void
    {
        $this->get('/api/admin/users', ['Accept' => 'text/html'])->assertStatus(401);
    }
}
