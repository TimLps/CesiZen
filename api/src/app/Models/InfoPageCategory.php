<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;
use OpenApi\Attributes as OA;

#[OA\Schema(
    schema: 'InfoPageCategory',
    title: 'Catégorie d\'articles d\'information (thème)',
    properties: [
        new OA\Property(property: 'id_info_page_category', type: 'integer', example: 1),
        new OA\Property(property: 'name',  type: 'string', example: 'Stress et anxiété'),
        new OA\Property(property: 'slug',  type: 'string', example: 'stress-et-anxiete'),
        new OA\Property(property: 'icon',  type: 'string', nullable: true),
        new OA\Property(property: 'color_hex', type: 'string', nullable: true, example: '#B0E0E6'),
        new OA\Property(property: 'sort_order', type: 'integer', example: 1),
        new OA\Property(property: 'is_active',  type: 'boolean', example: true),
    ]
)]
class InfoPageCategory extends Model
{
    use HasFactory;

    protected $table = 'info_page_categories';
    protected $primaryKey = 'id_info_page_category';
    public $incrementing = true;
    protected $keyType = 'int';

    protected $fillable = [
        'name',
        'slug',
        'icon',
        'color_hex',
        'sort_order',
        'is_active',
    ];

    protected $casts = [
        'is_active'  => 'boolean',
        'sort_order' => 'integer',
    ];

    public function pages(): HasMany
    {
        return $this->hasMany(InfoPage::class, 'id_info_page_category', 'id_info_page_category');
    }
}
