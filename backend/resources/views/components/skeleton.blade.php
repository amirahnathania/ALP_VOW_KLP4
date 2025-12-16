@props(['type' => 'table', 'rows' => 5])

@if($type === 'table')
    {{-- Skeleton for table view --}}
    <div class="animate-pulse">
        {{-- Header skeleton --}}
        <div class="hidden md:grid md:grid-cols-5 gap-4 p-4 bg-gray-50 border-b">
            <div class="h-4 bg-gray-300 rounded"></div>
            <div class="h-4 bg-gray-300 rounded"></div>
            <div class="h-4 bg-gray-300 rounded"></div>
            <div class="h-4 bg-gray-300 rounded"></div>
            <div class="h-4 bg-gray-300 rounded"></div>
        </div>

        {{-- Row skeletons --}}
        @for($i = 0; $i < $rows; $i++)
            <div class="hidden md:grid md:grid-cols-5 gap-4 p-4 border-b items-center">
                <div class="flex items-center space-x-3">
                    <div class="w-4 h-4 bg-gray-300 rounded"></div>
                    <div class="h-4 bg-gray-300 rounded w-24"></div>
                </div>
                <div class="h-4 bg-gray-300 rounded w-32"></div>
                <div class="h-4 bg-gray-300 rounded w-40"></div>
                <div class="h-6 bg-gray-300 rounded-full w-20"></div>
                <div class="flex space-x-2">
                    <div class="h-8 w-8 bg-gray-300 rounded"></div>
                    <div class="h-8 w-8 bg-gray-300 rounded"></div>
                </div>
            </div>
        @endfor
    </div>
@elseif($type === 'card')
    {{-- Skeleton for card/mobile view --}}
    <div class="animate-pulse space-y-4">
        @for($i = 0; $i < $rows; $i++)
            <div class="bg-white border rounded-lg p-4 space-y-3">
                <div class="flex items-center justify-between">
                    <div class="flex items-center space-x-3">
                        <div class="w-4 h-4 bg-gray-300 rounded"></div>
                        <div class="w-12 h-12 bg-gray-300 rounded-full"></div>
                        <div class="space-y-2">
                            <div class="h-4 bg-gray-300 rounded w-32"></div>
                            <div class="h-3 bg-gray-300 rounded w-24"></div>
                        </div>
                    </div>
                    <div class="h-6 bg-gray-300 rounded-full w-20"></div>
                </div>
                <div class="flex space-x-2">
                    <div class="h-8 bg-gray-300 rounded flex-1"></div>
                    <div class="h-8 bg-gray-300 rounded flex-1"></div>
                </div>
            </div>
        @endfor
    </div>
@elseif($type === 'stats')
    {{-- Skeleton for statistics/dashboard cards --}}
    <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4 animate-pulse">
        @for($i = 0; $i < 4; $i++)
            <div class="bg-white border rounded-lg p-6 space-y-3">
                <div class="h-4 bg-gray-300 rounded w-24"></div>
                <div class="h-8 bg-gray-300 rounded w-16"></div>
                <div class="h-3 bg-gray-300 rounded w-32"></div>
            </div>
        @endfor
    </div>
@elseif($type === 'profile')
    {{-- Skeleton for profile page --}}
    <div class="animate-pulse space-y-6">
        {{-- Avatar and name --}}
        <div class="flex items-center space-x-4">
            <div class="w-24 h-24 bg-gray-300 rounded-full"></div>
            <div class="space-y-2">
                <div class="h-6 bg-gray-300 rounded w-48"></div>
                <div class="h-4 bg-gray-300 rounded w-32"></div>
            </div>
        </div>

        {{-- Form fields --}}
        <div class="space-y-4">
            @for($i = 0; $i < 4; $i++)
                <div class="space-y-2">
                    <div class="h-4 bg-gray-300 rounded w-24"></div>
                    <div class="h-10 bg-gray-300 rounded"></div>
                </div>
            @endfor
        </div>

        {{-- Buttons --}}
        <div class="flex space-x-2">
            <div class="h-10 bg-gray-300 rounded w-32"></div>
            <div class="h-10 bg-gray-300 rounded w-32"></div>
        </div>
    </div>
@elseif($type === 'list')
    {{-- Skeleton for simple list --}}
    <div class="animate-pulse space-y-3">
        @for($i = 0; $i < $rows; $i++)
            <div class="flex items-center space-x-3 p-3 border rounded">
                <div class="w-10 h-10 bg-gray-300 rounded"></div>
                <div class="flex-1 space-y-2">
                    <div class="h-4 bg-gray-300 rounded w-3/4"></div>
                    <div class="h-3 bg-gray-300 rounded w-1/2"></div>
                </div>
            </div>
        @endfor
    </div>
@endif
