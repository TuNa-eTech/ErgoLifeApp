import type { Route } from "./+types/terms";
import { Navbar } from "~/components/Navbar";
import { Footer } from "~/components/Footer";

export function meta({}: Route.MetaArgs) {
  return [
    { title: "Terms of Service | ErgoLife" },
    { name: "description", content: "Terms of Service for ErgoLife application" },
  ];
}

export default function Terms() {
  return (
    <div className="bg-background-light text-navy antialiased min-h-screen flex flex-col font-body">
      <Navbar />
      
      <main className="flex-grow w-full px-6 py-6 md:py-10">
        <div className="mx-auto max-w-[1000px]">
          <div className="clay-card p-8 md:p-12">
            <header className="mb-10 text-center md:text-left">
              <h1 className="text-3xl md:text-5xl font-extrabold tracking-tight text-navy font-display mb-4">
                Terms of Service
              </h1>
              <p className="text-navy-light font-medium">Last updated: January 2026</p>
            </header>

            <div className="prose prose-lg prose-slate max-w-none prose-headings:font-display prose-headings:font-bold prose-headings:text-navy prose-p:text-navy-light prose-strong:text-navy prose-a:text-primary hover:prose-a:text-primary-hover">
              <section className="mb-8">
                <h2>1. Acceptance of Terms</h2>
                <p>
                  By accessing or using the ErgoLife application ("App"), you agree to be bound by these Terms of Service ("Terms"). If you do not agree to these Terms, you must not use the App.
                </p>
              </section>

              <section className="mb-8">
                <h2>2. Description of Service</h2>
                <p>
                  ErgoLife is a gamified productivity and habit-tracking application designed to help users manage chores, workouts, and daily tasks. We provide features such as task tracking, leaderboards, and family/group management ("House").
                </p>
              </section>

              <section className="mb-8">
                <h2>3. User Accounts</h2>
                <p>
                  To access certain features, you may be required to create an account. You are responsible for maintaining the confidentiality of your account credentials and for all activities that occur under your account. You agree to notify us immediately of any unauthorized use of your account.
                </p>
              </section>

              <section className="mb-8">
                <h2>4. User Conduct</h2>
                <p>
                  You agree not to use the App for any unlawful purpose or in any way that interrupts, damages, or impairs the service. This includes, but is not limited to, sending spam, hacking, or transmitting viruses.
                </p>
              </section>

              <section className="mb-8">
                <h2>5. Intellectual Property</h2>
                <p>
                  All content, features, and functionality of the App, including but not limited to design, text, graphics, and code, are the exclusive property of ErgoLife and are protected by international copyright, trademark, and other intellectual property laws.
                </p>
              </section>

              <section className="mb-8">
                <h2>6. Termination</h2>
                <p>
                  We may terminate or suspend your account and access to the App immediately, without prior notice or liability, for any reason, including without limitation if you breach the Terms.
                </p>
              </section>

              <section className="mb-8">
                <h2>7. Changes to Terms</h2>
                <p>
                  We reserve the right to modify or replace these Terms at any time. We will provide notice of any significant changes. Your continued use of the App following the posting of any changes constitutes acceptance of those changes.
                </p>
              </section>

              <section className="mb-8">
                <h2>8. Contact Us</h2>
                <p>
                  If you have any questions about these Terms, please contact us at <a href="mailto:support@ergolife.app">support@ergolife.app</a>.
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
