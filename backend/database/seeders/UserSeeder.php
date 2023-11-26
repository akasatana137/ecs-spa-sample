<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;

class UserSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        DB::table('users')->delete();
        DB::table('users')->insert([
            [
                'name' => 'tom',
                'email' => 'tom@gmail.com',
                'email_verified_at' => now(),
                'password' => Hash::make('12345@'),
                'created_at' => now(),
                'updated_at' => now()
            ],
            [
                'name' => 'james',
                'email' => 'james@gmail.com',
                'email_verified_at' => now(),
                'password' => Hash::make('12345@'),
                'created_at' => now(),
                'updated_at' => now()
            ],
        ]);
    }
}
