<?php

namespace Database\Factories;

use Illuminate\Database\Eloquent\Factories\Factory;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

/**
 * @extends \Illuminate\Database\Eloquent\Factories\Factory<\App\Models\User>
 */
class UserFactory extends Factory
{
    /**
     * The current password being used by the factory.
     */
    protected static ?string $password;

    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        $roles = ['ketua', 'gapoktan'];
        $role = fake()->randomElement($roles);
        $domain = $role === 'ketua' ? 'ketua.ac.id' : 'gapoktan.ac.id';

        return [
            'nama_pengguna' => fake()->name(),
            'email' => fake()->unique()->userName() . '@' . $domain,
            'email_verified_at' => now(),
            'password' => static::$password ??= Hash::make('Password123'),
            'remember_token' => Str::random(10),
        ];
    }

    /**
     * Indicate that the model's email address should be unverified.
     */
    public function unverified(): static
    {
        return $this->state(fn(array $attributes) => [
            'email_verified_at' => null,
        ]);
    }

    /**
     * Create a user with ketua role.
     */
    public function ketua(): static
    {
        return $this->state(fn(array $attributes) => [
            'email' => fake()->unique()->userName() . '@ketua.ac.id',
        ]);
    }

    /**
     * Create a user with gapoktan role.
     */
    public function gapoktan(): static
    {
        return $this->state(fn(array $attributes) => [
            'email' => fake()->unique()->userName() . '@gapoktan.ac.id',
        ]);
    }
}
