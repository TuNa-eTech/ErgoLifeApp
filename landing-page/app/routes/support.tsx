import type { Route } from "./+types/support";
import { Navbar } from "~/components/Navbar";
import { Footer } from "~/components/Footer";
import { Link } from "react-router";
import { useState } from "react";

export function meta({}: Route.MetaArgs) {
  return [
    { title: "Support | ErgoLife" },
    {
      name: "description",
      content: "Get help and support for ErgoLife. Frequently asked questions and contact information.",
    },
  ];
}

const SUPPORT_EMAIL = "anhtu.it.se@gmail.com";

function ContactForm() {
  const [name, setName] = useState("");
  const [email, setEmail] = useState("");
  const [subject, setSubject] = useState("");
  const [message, setMessage] = useState("");

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    
    const emailSubject = `[ErgoLife Support] ${subject}`;
    const emailBody = `Name: ${name}
Email: ${email}

Subject: ${subject}

Message:
${message}`;
    
    const mailtoUrl = `mailto:${SUPPORT_EMAIL}?subject=${encodeURIComponent(emailSubject)}&body=${encodeURIComponent(emailBody)}`;
    window.location.href = mailtoUrl;
  };

  return (
    <div className="clay-card p-8">
      <div className="flex items-center gap-3 mb-6">
        <div className="w-12 h-12 bg-gradient-to-br from-primary to-primary-hover rounded-xl flex items-center justify-center text-white">
          <span className="material-symbols-outlined text-2xl">send</span>
        </div>
        <h3 className="text-xl font-bold text-navy">Send us a message</h3>
      </div>
      
      <form onSubmit={handleSubmit} className="space-y-4">
        <div>
          <label htmlFor="name" className="block text-sm font-semibold text-navy mb-2">
            Your Name
          </label>
          <input
            type="text"
            id="name"
            value={name}
            onChange={(e) => setName(e.target.value)}
            required
            placeholder="John Doe"
            className="w-full px-4 py-3 rounded-xl border-2 border-gray-200 focus:border-primary focus:outline-none transition-colors bg-white text-navy placeholder:text-gray-400"
          />
        </div>

        <div>
          <label htmlFor="email" className="block text-sm font-semibold text-navy mb-2">
            Email Address
          </label>
          <input
            type="email"
            id="email"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
            required
            placeholder="john@example.com"
            className="w-full px-4 py-3 rounded-xl border-2 border-gray-200 focus:border-primary focus:outline-none transition-colors bg-white text-navy placeholder:text-gray-400"
          />
        </div>

        <div>
          <label htmlFor="subject" className="block text-sm font-semibold text-navy mb-2">
            Subject
          </label>
          <select
            id="subject"
            value={subject}
            onChange={(e) => setSubject(e.target.value)}
            required
            className="w-full px-4 py-3 rounded-xl border-2 border-gray-200 focus:border-primary focus:outline-none transition-colors bg-white text-navy"
          >
            <option value="">Select a topic...</option>
            <option value="General Inquiry">General Inquiry</option>
            <option value="Account Issue">Account Issue</option>
            <option value="Bug Report">Bug Report</option>
            <option value="Feature Request">Feature Request</option>
            <option value="Billing Question">Billing Question</option>
            <option value="Other">Other</option>
          </select>
        </div>

        <div>
          <label htmlFor="message" className="block text-sm font-semibold text-navy mb-2">
            Message
          </label>
          <textarea
            id="message"
            value={message}
            onChange={(e) => setMessage(e.target.value)}
            required
            rows={4}
            placeholder="How can we help you?"
            className="w-full px-4 py-3 rounded-xl border-2 border-gray-200 focus:border-primary focus:outline-none transition-colors bg-white text-navy placeholder:text-gray-400 resize-none"
          />
        </div>

        <button
          type="submit"
          className="w-full py-3 px-6 bg-gradient-to-r from-primary to-primary-hover text-white font-bold rounded-xl hover:shadow-lg hover:scale-[1.02] transition-all duration-300 flex items-center justify-center gap-2"
        >
          <span className="material-symbols-outlined text-xl">send</span>
          Send Message
        </button>
      </form>
    </div>
  );
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

          {/* Contact Section */}
          <div className="grid md:grid-cols-2 gap-6">
            {/* Email Support Card */}
            <div className="clay-card p-8 flex flex-col items-center text-center hover:scale-[1.02] transition-transform duration-300">
              <div className="w-16 h-16 bg-primary/10 rounded-2xl flex items-center justify-center mb-6 text-primary">
                <span className="material-symbols-outlined text-3xl">mail</span>
              </div>
              <h3 className="text-xl font-bold text-navy mb-2">Email Support</h3>
              <p className="text-navy-light mb-6">
                For general inquiries, account issues, or feedback. We usually respond within 24 hours.
              </p>
              <a 
                href="mailto:anhtu.it.se@gmail.com" 
                className="text-primary font-bold hover:text-primary-hover transition-colors"
              >
                anhtu.it.se@gmail.com
              </a>
            </div>

            {/* Contact Form Card */}
            <ContactForm />
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
