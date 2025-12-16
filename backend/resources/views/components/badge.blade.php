@props([
    'variant' => 'primary', // primary, secondary, success, danger, warning, info
])

@php
$variantClasses = [
    'primary' => 'bg-[#386158]/10 text-[#386158]',
    'secondary' => 'bg-gray-100 text-gray-600',
    'success' => 'bg-green-100 text-green-700',
    'danger' => 'bg-red-100 text-red-700',
    'warning' => 'bg-yellow-100 text-yellow-700',
    'info' => 'bg-blue-100 text-blue-700',
];

$classes = 'inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ' . $variantClasses[$variant];
@endphp

<span {{ $attributes->merge(['class' => $classes]) }}>
    {{ $slot }}
</span>
