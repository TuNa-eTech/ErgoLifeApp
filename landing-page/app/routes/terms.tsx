
import type { Route } from "./+types/terms";

export function meta({}: Route.MetaArgs) {
  return [
    { title: "Terms of Service | ErgoLife" },
    { name: "description", content: "Terms of Service for ErgoLife application" },
  ];
}

export default function Terms() {
  return (
    <div className="min-h-screen bg-white text-gray-900 px-4 py-8 md:px-8 lg:px-16">
      <main className="max-w-3xl mx-auto">
        <header className="mb-12">
          <h1 className="text-3xl font-bold tracking-tight text-gray-900 sm:text-4xl mb-2">Terms of Service</h1>
          <p className="text-gray-500">Last updated: January 2026</p>
        </header>

        <div className="prose prose-slate max-w-none prose-headings:font-semibold prose-a:text-blue-600">
          <section className="mb-8">
            <h2 className="text-xl font-semibold mb-4 text-gray-900">1. Acceptance of Terms</h2>
            <p className="text-gray-700 leading-relaxed mb-4">
              By accessing or using the ErgoLife application ("App"), you agree to be bound by these Terms of Service ("Terms"). If you do not agree to these Terms, you must not use the App.
            </p>
          </section>

          <section className="mb-8">
            <h2 className="text-xl font-semibold mb-4 text-gray-900">2. Description of Service</h2>
            <p className="text-gray-700 leading-relaxed mb-4">
              ErgoLife is a gamified productivity and habit-tracking application designed to help users manage chores, workouts, and daily tasks. We provide features such as task tracking, leaderboards, and family/group management ("House").
            </p>
          </section>

          <section className="mb-8">
            <h2 className="text-xl font-semibold mb-4 text-gray-900">3. User Accounts</h2>
            <p className="text-gray-700 leading-relaxed mb-4">
              To access certain features, you may be required to create an account. You are responsible for maintaining the confidentiality of your account credentials and for all activities that occur under your account. You agree to notify us immediately of any unauthorized use of your account.
            </p>
          </section>

          <section className="mb-8">
            <h2 className="text-xl font-semibold mb-4 text-gray-900">4. User Conduct</h2>
            <p className="text-gray-700 leading-relaxed mb-4">
              You agree not to use the App for any unlawful purpose or in any way that interrupts, damages, or impairs the service. This includes, but is not limited to, sending spam, hacking, or transmitting viruses.
            </p>
          </section>

          <section className="mb-8">
            <h2 className="text-xl font-semibold mb-4 text-gray-900">5. Intellectual Property</h2>
            <p className="text-gray-700 leading-relaxed mb-4">
              All content, features, and functionality of the App, including but not limited to design, text, graphics, and code, are the exclusive property of ErgoLife and are protected by international copyright, trademark, and other intellectual property laws.
            </p>
          </section>

          <section className="mb-8">
            <h2 className="text-xl font-semibold mb-4 text-gray-900">6. Termination</h2>
            <p className="text-gray-700 leading-relaxed mb-4">
              We may terminate or suspend your account and access to the App immediately, without prior notice or liability, for any reason, including without limitation if you breach the Terms.
            </p>
          </section>

          <section className="mb-8">
            <h2 className="text-xl font-semibold mb-4 text-gray-900">7. Changes to Terms</h2>
            <p className="text-gray-700 leading-relaxed mb-4">
              We reserve the right to modify or replace these Terms at any time. We will provide notice of any significant changes. Your continued use of the App following the posting of any changes constitutes acceptance of those changes.
            </p>
          </section>

          <section className="mb-8">
            <h2 className="text-xl font-semibold mb-4 text-gray-900">8. Contact Us</h2>
            <p className="text-gray-700 leading-relaxed mb-4">
              If you have any questions about these Terms, please contact us at support@ergolife.app.
            </p>
          </section>
        </div>
      </main>
    </div>
  );
}
