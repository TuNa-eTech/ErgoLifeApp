import type { Route } from "./+types/privacy";
import { Navbar } from "~/components/Navbar";
import { Footer } from "~/components/Footer";

export function meta({}: Route.MetaArgs) {
  return [
    { title: "Privacy Policy | ErgoLife" },
    { name: "description", content: "Privacy Policy for ErgoLife application" },
  ];
}

export default function Privacy() {
  return (
    <div className="bg-background-light text-navy antialiased min-h-screen flex flex-col font-body">
      <Navbar />

      <main className="flex-grow w-full px-6 py-6 md:py-10">
        <div className="mx-auto max-w-[1000px]">
          <div className="clay-card p-8 md:p-12">
            <header className="mb-10 text-center md:text-left">
              <h1 className="text-3xl md:text-5xl font-extrabold tracking-tight text-navy font-display mb-4">
                Privacy Policy
              </h1>
              <p className="text-navy-light font-medium">Last updated: January 2026</p>
            </header>

            <div className="prose prose-lg prose-slate max-w-none prose-headings:font-display prose-headings:font-bold prose-headings:text-navy prose-p:text-navy-light prose-strong:text-navy prose-li:text-navy-light prose-a:text-primary hover:prose-a:text-primary-hover">
              <section className="mb-8">
                <h2>1. Introduction</h2>
                <p>
                  ErgoLife ("we", "our", or "us") respects your privacy and is committed to protecting your personal data. This Privacy Policy explains how we collect, use, disclosure, and safeguard your information when you use our mobile application.
                </p>
              </section>

              <section className="mb-8">
                <h2>2. Information We Collect</h2>
                <p>We may collect information about you in a variety of ways:</p>
                <ul>
                  <li><strong>Personal Data:</strong> Personally identifiable information, such as your name, email address, and profile image, that you voluntarily give to us when you register.</li>
                  <li><strong>Activity Data:</strong> Data related to your tasks, extensive progress, streaks, and other gamification metrics.</li>
                  <li><strong>Device Data:</strong> Information about your mobile device, such as device ID, model, and operating system version.</li>
                </ul>
              </section>

              <section className="mb-8">
                <h2>3. How We Use Your Information</h2>
                <p>We use the collected information to:</p>
                <ul>
                  <li>Create and manage your account.</li>
                  <li>Provide personalized gamification features and leaderboards.</li>
                  <li>Improve the efficiency and operation of the App.</li>
                  <li>Monitor and analyze usage and trends to improve your experience.</li>
                  <li>Notify you of updates and new features.</li>
                </ul>
              </section>

              <section className="mb-8">
                <h2>4. Disclosure of Your Information</h2>
                <p>We may share information we have collected about you in certain situations. Your information may be disclosed as follows:</p>
                <ul>
                  <li><strong>By Law or to Protect Rights:</strong> If we believe the release of information about you is necessary to respond to legal process, to investigate or remedy potential violations of our policies, or to protect the rights, property, and safety of others.</li>
                  <li><strong>With Service Providers:</strong> We may share your information with third parties that perform services for us or on our behalf, including data analysis, email delivery, hosting services, and customer service.</li>
                </ul>
              </section>

              <section className="mb-8">
                <h2>5. Security of Your Information</h2>
                <p>
                  We use administrative, technical, and physical security measures to help protect your personal information. While we have taken reasonable steps to secure the personal information you provide to us, please be aware that despite our efforts, no security measures are perfect or impenetrable, and no method of data transmission can be guaranteed against any interception or other type of misuse.
                </p>
              </section>

              <section className="mb-8">
                <h2>6. Contact Us</h2>
                <p>
                  If you have questions or comments about this Privacy Policy, please contact us at <a href="mailto:privacy@ergolife.app">privacy@ergolife.app</a>.
                </p>
              </section>
            </div>
          </div>
        </div>
      </main>

      <Footer />
    </div>
  );
}
