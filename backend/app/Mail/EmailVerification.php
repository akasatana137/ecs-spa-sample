<?php

namespace App\Mail;

use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Mail\Mailable;
use Illuminate\Mail\Mailables\Content;
use Illuminate\Mail\Mailables\Envelope;
use Illuminate\Queue\SerializesModels;

class EmailVerification extends Mailable
{
    use Queueable, SerializesModels;

    public $email;
    public $token;

    /**
     * Create a new message instance.
     */
    public function __construct($notifiable)
    {
        $this->email = $notifiable->email;
        $this->token = $notifiable->email_verification_token;
    }

    /**
     * Get the message envelope.
     */
    public function envelope(): Envelope
    {
        return new Envelope(
            subject: 'メールアドレス認証',
        );
    }

    /**
     * Get the message content definition.
     */
    public function content(): Content
    {
        // $url = route('verification.verify', [
        //     'email' => $this->email,
        //     'token' => $this->token
        // ]);
        $frontend = env("SANCTUM_STATEFUL_DOMAINS", "http://localhost:3000");
        $url = "{$frontend}/{$this->email}/{$this->token}";
        return new Content(
            view: 'emails.verify',
            with: ['url' => $url]
        );
    }

    /**
     * Get the attachments for the message.
     *
     * @return array<int, \Illuminate\Mail\Mailables\Attachment>
     */
    public function attachments(): array
    {
        return [];
    }
}
