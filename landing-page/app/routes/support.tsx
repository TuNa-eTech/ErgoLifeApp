import type { Route } from "./+types/support";
import { Navbar } from "~/components/Navbar";
import { Footer } from "~/components/Footer";
import { Link } from "react-router";

export function meta({}: Route.MetaArgs) {
  return [
    { title: "Support | ErgoLife" },
    {
      name: "description",
      content: "Get help and support for ErgoLife. Frequently asked questions and contact information.",
    },
  ];
}

export default function Support() {
  return (
    <div className="bg-background-light text-navy antialiased min-h-screen flex flex-col font-body">
      <Navbar />

      <main className="flex-grow w-full px-6 py-6 md:py-10">
        <div className="mx-auto max-w-[1000px] space-y-8">
          {/* Header Section */}
          <div className="clay-card p-10 md:p-14 text-center">
            <h1 className="text-4xl md:text-5xl font-extrabold tracking-tight text-navy font-display mb-6">
              How can we help?
            </h1>
            <p className="text-xl text-navy-light font-medium max-w-2xl mx-auto leading-relaxed">
              Find answers to common questions or get in touch with our team.
              We're here to help you get the most out of ErgoLife.
            </p>
          </div>

          {/* Contact Cards */}
          <div className="grid md:grid-cols-2 gap-6">
            <div className="clay-card p-8 flex flex-col items-center text-center hover:scale-[1.02] transition-transform duration-300">
              <div className="w-16 h-16 bg-primary/10 rounded-2xl flex items-center justify-center mb-6 text-primary">
                <span className="material-symbols-outlined text-3xl">mail</span>
              </div>
              <h3 className="text-xl font-bold text-navy mb-2">Email Support</h3>
              <p className="text-navy-light mb-6">
                For general inquiries, account issues, or feedback. We usually respond within 24 hours.
              </p>
              <a 
                href="mailto:support@ergolife.app" 
                className="text-primary font-bold hover:text-primary-hover transition-colors"
              >
                support@ergolife.app
              </a>
            </div>

            <div className="clay-card p-8 flex flex-col items-center text-center hover:scale-[1.02] transition-transform duration-300">
               <div className="w-16 h-16 bg-blue-100 rounded-2xl flex items-center justify-center mb-6 text-blue-600">
                <span className="material-symbols-outlined text-3xl">chat</span>
              </div>
              <h3 className="text-xl font-bold text-navy mb-2">Live Chat</h3>
              <p className="text-navy-light mb-6">
                Available inside the mobile app for Premium users.
              </p>
              <span className="text-navy/60 font-medium">
                Mon - Fri, 9am - 5pm EST
              </span>
            </div>
          </div>

          {/* FAQ Section */}
          <div className="clay-card p-8 md:p-12">
            <h2 className="text-3xl font-bold text-navy font-display mb-8">
              Frequently Asked Questions
            </h2>
            <div className="space-y-6">
              <details className="group border-b border-gray-100 pb-6 cursor-pointer">
                <summary className="flex justify-between items-center font-bold text-lg text-navy list-none">
                  <span>Is ErgoLife free to use?</span>
                  <span className="transition-transform group-open:rotate-180 material-symbols-outlined text-gray-400">expand_more</span>
                </summary>
                <p className="text-navy-light mt-4 leading-relaxed">
                  Yes! The core features of ErgoLife, including task tracking, basic gamification, and creating a House, are completely free. We also offer a Premium subscription for advanced stats, unlimited history, and exclusive rewards.
                </p>
              </details>

              <details className="group border-b border-gray-100 pb-6 cursor-pointer">
                <summary className="flex justify-between items-center font-bold text-lg text-navy list-none">
                  <span>How do I invite family members?</span>
                  <span className="transition-transform group-open:rotate-180 material-symbols-outlined text-gray-400">expand_more</span>
                </summary>
                <p className="text-navy-light mt-4 leading-relaxed">
                  Go to the "House" tab in the app and tap on "Manage Members". You can send an invite link directly via message or email. They'll need to download the app to join.
                </p>
              </details>

              <details className="group border-b border-gray-100 pb-6 cursor-pointer">
                <summary className="flex justify-between items-center font-bold text-lg text-navy list-none">
                  <span>Can I sync with other fitness apps?</span>
                  <span className="transition-transform group-open:rotate-180 material-symbols-outlined text-gray-400">expand_more</span>
                </summary>
                <p className="text-navy-light mt-4 leading-relaxed">
                  Currently, we support syncing with Apple Health and Google Fit. You can enable this in the Settings menu under "Integrations".
                </p>
              </details>

              <details className="group cursor-pointer">
                <summary className="flex justify-between items-center font-bold text-lg text-navy list-none">
                  <span>How are calories calculated for chores?</span>
                  <span className="transition-transform group-open:rotate-180 material-symbols-outlined text-gray-400">expand_more</span>
                </summary>
                <p className="text-navy-light mt-4 leading-relaxed">
                  We use standard MET (Metabolic Equivalent of Task) values for various household activities combined with your profile data (weight, height, age) to estimate calorie burn.
                </p>
              </details>
            </div>
          </div>
        </div>
      </main>

      <Footer />
    </div>
  );
}
