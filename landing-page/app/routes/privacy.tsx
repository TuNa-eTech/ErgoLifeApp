
import type { Route } from "./+types/privacy";

export function meta({}: Route.MetaArgs) {
  return [
    { title: "Privacy Policy | ErgoLife" },
    { name: "description", content: "Privacy Policy for ErgoLife application" },
  ];
}

export default function Privacy() {
  return (
    <div className="min-h-screen bg-white text-gray-900 px-4 py-8 md:px-8 lg:px-16">
      <main className="max-w-3xl mx-auto">
        <header className="mb-12">
          <h1 className="text-3xl font-bold tracking-tight text-gray-900 sm:text-4xl mb-2">Privacy Policy</h1>
          <p className="text-gray-500">Last updated: January 2026</p>
        </header>

        <div className="prose prose-slate max-w-none prose-headings:font-semibold prose-a:text-blue-600">
          <section className="mb-8">
            <h2 className="text-xl font-semibold mb-4 text-gray-900">1. Introduction</h2>
            <p className="text-gray-700 leading-relaxed mb-4">
              ErgoLife ("we", "our", or "us") respects your privacy and is committed to protecting your personal data. This Privacy Policy explains how we collect, use, disclosure, and safeguard your information when you use our mobile application.
            </p>
          </section>

          <section className="mb-8">
            <h2 className="text-xl font-semibold mb-4 text-gray-900">2. Information We Collect</h2>
            <div className="text-gray-700 leading-relaxed mb-4">
              <p className="mb-2">We may collect information about you in a variety of ways:</p>
              <ul className="list-disc pl-5 space-y-2">
                <li><strong>Personal Data:</strong> Personally identifiable information, such as your name, email address, and profile image, that you voluntarily give to us when you register.</li>
                <li><strong>Activity Data:</strong> Data related to your tasks, extensive progress, streaks, and other gamification metrics.</li>
                <li><strong>Device Data:</strong> Information about your mobile device, such as device ID, model, and operating system version.</li>
              </ul>
            </div>
          </section>

          <section className="mb-8">
            <h2 className="text-xl font-semibold mb-4 text-gray-900">3. How We Use Your Information</h2>
            <p className="text-gray-700 leading-relaxed mb-4">
              We use the collected information to:
            </p>
            <ul className="list-disc pl-5 space-y-2 text-gray-700">
              <li>Create and manage your account.</li>
              <li>Provide personalized gamification features and leaderboards.</li>
              <li>Improve the efficiency and operation of the App.</li>
              <li>Monitor and analyze usage and trends to improve your experience.</li>
              <li>Notify you of updates and new features.</li>
            </ul>
          </section>

          <section className="mb-8">
            <h2 className="text-xl font-semibold mb-4 text-gray-900">4. Disclosure of Your Information</h2>
            <p className="text-gray-700 leading-relaxed mb-4">
              We may share information we have collected about you in certain situations. Your information may be disclosed as follows:
            </p>
            <ul className="list-disc pl-5 space-y-2 text-gray-700">
              <li><strong>By Law or to Protect Rights:</strong> If we believe the release of information about you is necessary to respond to legal process, to investigate or remedy potential violations of our policies, or to protect the rights, property, and safety of others.</li>
              <li><strong>With Service Providers:</strong> We may share your information with third parties that perform services for us or on our behalf, including data analysis, email delivery, hosting services, and customer service.</li>
            </ul>
          </section>

          <section className="mb-8">
            <h2 className="text-xl font-semibold mb-4 text-gray-900">5. Security of Your Information</h2>
            <p className="text-gray-700 leading-relaxed mb-4">
              We use administrative, technical, and physical security measures to help protect your personal information. While we have taken reasonable steps to secure the personal information you provide to us, please be aware that despite our efforts, no security measures are perfect or impenetrable, and no method of data transmission can be guaranteed against any interception or other type of misuse.
            </p>
          </section>

          <section className="mb-8">
            <h2 className="text-xl font-semibold mb-4 text-gray-900">6. Contact Us</h2>
            <p className="text-gray-700 leading-relaxed mb-4">
              If you have questions or comments about this Privacy Policy, please contact us at privacy@ergolife.app.
            </p>
          </section>
        </div>
      </main>
    </div>
  );
}
