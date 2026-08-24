<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\SoftDeletes;
use OpenApi\Attributes as OA;

#[OA\Schema(
    schema: 'InfoPage',
    title: 'Page d\'information',
    description: 'Page d\'information éditoriale (santé mentale, prévention, etc.)',
    properties: [
        new OA\Property(property: 'id_info_page', type: 'integer', example: 1),
        new OA\Property(property: 'slug', type: 'string', example: 'comprendre-le-stress'),
        new OA\Property(property: 'title', type: 'string', example: 'Comprendre le stress'),
        new OA\Property(property: 'menu_label', type: 'string', example: 'Le stress'),
        new OA\Property(property: 'content', type: 'string', example: '<p>Le stress est...</p>'),
        new OA\Property(property: 'id_info_page_category', type: 'integer', nullable: true),
        new OA\Property(property: 'sort_order', type: 'integer', example: 1),
        new OA\Property(property: 'is_published', type: 'boolean', example: true),
    ]
)]
class InfoPage extends Model
{
    use HasFactory, SoftDeletes;

    protected $table = 'info_pages';
    protected $primaryKey = 'id_info_page';
    public $incrementing = true;
    protected $keyType = 'int';

    protected $fillable = [
        'slug',
        'title',
        'menu_label',
        'content',
        'id_info_page_category',
        'created_by',
        'updated_by',
        'sort_order',
        'is_published',
    ];

    protected $casts = [
        'is_published' => 'boolean',
        'sort_order'   => 'integer',
        'created_at'   => 'datetime',
        'updated_at'   => 'datetime',
    ];

    public function scopePublished($query)
    {
        return $query->where('is_published', true);
    }

    public function category(): BelongsTo
    {
        return $this->belongsTo(InfoPageCategory::class, 'id_info_page_category', 'id_info_page_category');
    }

    public function creator(): BelongsTo
    {
        return $this->belongsTo(User::class, 'created_by', 'id_user');
    }

    public function lastEditor(): BelongsTo
    {
        return $this->belongsTo(User::class, 'updated_by', 'id_user');
    }
}
