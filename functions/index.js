if (process.env.GOOGLE_APPLICATION_CREDENTIALS && !process.env.GOOGLE_APPLICATION_CREDENTIALS.endsWith('.json')) {
  delete process.env.GOOGLE_APPLICATION_CREDENTIALS;
}

const { onRequest } = require("firebase-functions/v2/https");
const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const admin = require("firebase-admin");
const nodemailer = require("nodemailer");
const cors = require("cors")({ origin: true });

admin.initializeApp();

const transporter = nodemailer.createTransport({
  host: "smtpout.secureserver.net",
  port: 465,
  secure: true,
  auth: {
    user: "vishal@avmglobalconsultants.com",
    pass: "avmglobalconsultants@113",
  },
});

function getEmailHtml(name, jobTitle, email, phone) {
  return `
<div style="font-family: 'Segoe UI', Arial, sans-serif; max-width: 600px; margin: 0 auto; background-color: #ffffff; border: 1px solid #e2e8f0; border-radius: 12px; overflow: hidden;">
  <div style="background: linear-gradient(135deg, #0A192F 0%, #146EB8 100%); padding: 28px 24px; text-align: center; color: #ffffff;">
    <h1 style="margin: 0 0 6px 0; font-size: 22px; font-weight: 700; color: #ffffff;">AVM Global Consultants</h1>
    <p style="margin: 0; font-size: 13px; color: #e2e8f0;">Government-Approved Overseas Placement & Manpower Consultants</p>
  </div>
  <div style="padding: 28px 24px; color: #1e293b;">
    <div style="display: inline-block; background-color: #e0f2fe; color: #0284c7; font-weight: 600; font-size: 12px; padding: 4px 12px; border-radius: 16px; margin-bottom: 16px;">
      Application Received Successfully
    </div>
    <h2 style="font-size: 18px; color: #0f172a; margin: 0 0 12px 0;">Dear ${name},</h2>
    <p style="font-size: 14px; line-height: 1.6; color: #334155; margin: 0 0 16px 0;">
      Thank you for applying for the position of <strong>${jobTitle}</strong> through <strong>AVM Global Consultants</strong>. We have successfully received your application details and resume.
    </p>
    <div style="background-color: #f8fafc; border: 1px solid #e2e8f0; border-radius: 8px; padding: 16px; margin-bottom: 20px;">
      <div style="font-weight: 600; font-size: 13px; color: #0f172a; margin-bottom: 10px; border-bottom: 1px solid #e2e8f0; padding-bottom: 6px;">Application Overview</div>
      <p style="margin: 4px 0; font-size: 13px; color: #475569;"><strong>Job Position:</strong> ${jobTitle}</p>
      <p style="margin: 4px 0; font-size: 13px; color: #475569;"><strong>Applicant Name:</strong> ${name}</p>
      <p style="margin: 4px 0; font-size: 13px; color: #475569;"><strong>Registered Email:</strong> ${email}</p>
      <p style="margin: 4px 0; font-size: 13px; color: #475569;"><strong>Contact Number:</strong> ${phone}</p>
    </div>
    <p style="font-size: 14px; line-height: 1.6; color: #334155; margin: 0 0 16px 0;">
      Our overseas recruitment specialists are reviewing your profile. If your qualifications match the employer's requirements, our team will reach out to guide you through the interview and placement process.
    </p>
    <p style="font-size: 14px; line-height: 1.6; color: #334155; margin: 0;">
      Warm regards,<br/>
      <strong>AVM Global Consultants Recruitment Team</strong><br/>
      <span style="font-size: 12px; color: #64748b;">Email: vishal@avmglobalconsultants.com</span>
    </p>
  </div>
  <div style="background-color: #f1f5f9; padding: 16px 24px; text-align: center; font-size: 12px; color: #64748b; border-top: 1px solid #e2e8f0;">
    <p style="margin: 0 0 4px 0;">&copy; ${new Date().getFullYear()} AVM Global Consultants. All rights reserved.</p>
    <p style="margin: 0;"><a href="https://avmglobalconsultants.com" style="color: #146EB8; text-decoration: none;">avmglobalconsultants.com</a></p>
  </div>
</div>
`;
}

function getEmailText(name, jobTitle, email, phone) {
  return `Dear ${name},

Thank you for applying for the position of "${jobTitle}" with AVM Global Consultants.

We have successfully received your application and resume. Our overseas recruitment team will review your qualifications and experience against the client's criteria. If your profile is shortlisted, our recruitment team will get in touch with you for the next steps.

Application Summary:
• Position: ${jobTitle}
• Candidate Name: ${name}
• Email: ${email}
• Contact Number: ${phone}

For any queries, contact us at vishal@avmglobalconsultants.com or visit our website: https://avmglobalconsultants.com.

Best regards,
Recruitment & Placement Team
AVM Global Consultants
(Government-Approved Overseas Recruitment Consultants)`;
}

// 1. Automatic Firestore Trigger on Application Creation
exports.onApplicationCreated = onDocumentCreated("job_applications/{docId}", async (event) => {
  const data = event.data?.data();
  if (!data) return;

  const email = data.applicantEmail;
  const name = data.applicantName || "Candidate";
  const jobTitle = data.jobTitle || "Job Position";
  const phone = data.applicantPhone || "N/A";

  if (!email) {
    console.log("No applicant email found in document");
    return;
  }

  try {
    const mailOptions = {
      from: '"AVM Global Consultants" <vishal@avmglobalconsultants.com>',
      to: email,
      subject: `Application Received: ${jobTitle} | AVM Global Consultants`,
      text: getEmailText(name, jobTitle, email, phone),
      html: getEmailHtml(name, jobTitle, email, phone),
    };

    const info = await transporter.sendMail(mailOptions);
    console.log(`Confirmation email sent to ${email}. Message ID: ${info.messageId}`);
  } catch (error) {
    console.error("Error sending confirmation email via Firestore trigger:", error);
  }
});

// 2. HTTPS Endpoint Callable directly from Web
exports.sendConfirmationEmail = onRequest({ cors: true }, async (req, res) => {
  cors(req, res, async () => {
    if (req.method !== "POST") {
      return res.status(405).json({ error: "Method Not Allowed" });
    }

    const { email, name, jobTitle, phone } = req.body;
    if (!email) {
      return res.status(400).json({ error: "Email is required" });
    }

    try {
      const mailOptions = {
        from: '"AVM Global Consultants" <vishal@avmglobalconsultants.com>',
        to: email,
        subject: `Application Received: ${jobTitle || "Job Position"} | AVM Global Consultants`,
        text: getEmailText(name || "Candidate", jobTitle || "Job Position", email, phone || "N/A"),
        html: getEmailHtml(name || "Candidate", jobTitle || "Job Position", email, phone || "N/A"),
      };

      const info = await transporter.sendMail(mailOptions);
      console.log(`Confirmation email sent directly via HTTPS to ${email}. Message ID: ${info.messageId}`);
      return res.status(200).json({ success: true, messageId: info.messageId });
    } catch (error) {
      console.error("Error sending email via HTTPS endpoint:", error);
      return res.status(500).json({ error: error.message });
    }
  });
});

/**
 * Helper to sanitize topic names for Firebase Cloud Messaging
 * Must conform to: [a-zA-Z0-9-_.~%]{1,900}
 */
function sanitizeTopic(str) {
  if (!str) return "general";
  const sanitized = str
    .toLowerCase()
    .trim()
    .replace(/[^a-zA-Z0-9]/g, "_")
    .replace(/_+/g, "_")
    .replace(/^_+|_+$/g, "");
  return sanitized.length > 0 ? sanitized : "general";
}

/**
 * Telephony API Gateway Helper Stub (Twilio SMS Integration)
 * Standardized interface to dispatch SMS alerts to offline candidates and direct applicants.
 * 
 * To enable live dispatch:
 * 1. Define environment secrets / config: TWILIO_ACCOUNT_SID, TWILIO_AUTH_TOKEN, TWILIO_PHONE_NUMBER
 * 2. npm install twilio
 */
async function sendTwilioSms(phoneNumber, message) {
  if (!phoneNumber || phoneNumber === "N/A") {
    console.log("[Twilio SMS] Skipped: No phone number provided.");
    return false;
  }

  const accountSid = process.env.TWILIO_ACCOUNT_SID;
  const authToken = process.env.TWILIO_AUTH_TOKEN;
  const fromPhone = process.env.TWILIO_PHONE_NUMBER || "+1234567890";

  if (!accountSid || !authToken) {
    console.log(
      `[Twilio SMS Gateway STUB] Ready for binding. Mock dispatch to ${phoneNumber}: "${message}"`
    );
    return true;
  }

  try {
    // const twilio = require("twilio")(accountSid, authToken);
    // const response = await twilio.messages.create({
    //   body: message,
    //   from: fromPhone,
    //   to: phoneNumber,
    // });
    // console.log(`[Twilio SMS] Sent to ${phoneNumber}, SID: ${response.sid}`);
    return true;
  } catch (error) {
    console.error(`[Twilio SMS Error] Failed to send SMS to ${phoneNumber}:`, error);
    return false;
  }
}

// 3. Deployment-ready Cloud Function: onJobUploaded
// Triggered on creation of a new job document in Firestore 'jobs/{jobId}'
exports.onJobUploaded = onDocumentCreated("jobs/{jobId}", async (event) => {
  const job = event.data?.data();
  if (!job) {
    console.log("No job data found in event payload.");
    return;
  }

  const jobId = event.params.jobId;
  const title = job.title || "New Job Position";
  const company = job.company || "AVM Global Consultants";
  const location = job.location || "International";
  const type = job.type || "Full-time";
  const description = job.description || "";
  const requirements = job.requirements || "";

  console.log(`Processing new job upload: "${title}" (ID: ${jobId})`);
  const baseUrl = "https://avmglobalconsultants.com";
  const defaultJobUrl = `${baseUrl}/jobs?query=${encodeURIComponent(title)}&id=${encodeURIComponent(jobId)}`;

  // --- Step A: Broadcast to FCM Search Topics ---
  const topicKeywords = new Set();
  topicKeywords.add("all");
  topicKeywords.add(sanitizeTopic(title));
  if (type) topicKeywords.add(sanitizeTopic(type));

  // Extract individual keywords from job title
  const titleTokens = title.toLowerCase().split(/[\s,/-]+/);
  for (const token of titleTokens) {
    if (token.length >= 3) {
      topicKeywords.add(sanitizeTopic(token));
    }
  }

  const jobTag = `job_${jobId}`;
  const dispatchedTopics = new Set();

  for (const keyword of topicKeywords) {
    const topicName = `job_search_${keyword}`;
    if (dispatchedTopics.has(topicName)) continue;
    dispatchedTopics.add(topicName);

    const topicJobUrl = `${baseUrl}/jobs?query=${encodeURIComponent(keyword === 'all' ? title : keyword)}&id=${encodeURIComponent(jobId)}`;

    try {
      await admin.messaging().send({
        topic: topicName,
        notification: {
          title: `New Opening: ${title}`,
          body: `${company} is hiring for ${title} (${location}). Apply now via AVM Global!`,
        },
        data: {
          title: `New Opening: ${title}`,
          body: `${company} is hiring for ${title} (${location}). Apply now via AVM Global!`,
          jobId: String(jobId),
          jobTitle: String(title),
          company: String(company),
          location: String(location),
          url: String(topicJobUrl),
          click_action: String(topicJobUrl),
          tag: String(jobTag),
        },
        webpush: {
          headers: {
            Urgency: "high",
            Topic: jobTag,
          },
          notification: {
            title: `New Opening: ${title}`,
            body: `${company} is hiring for ${title} (${location}). Apply now via AVM Global!`,
            icon: "https://avmglobalconsultants.com/icons/Icon-192.png",
            tag: jobTag,
            renotify: false,
          },
          fcmOptions: {
            link: topicJobUrl,
          },
        },
      });
      console.log(`[FCM Broadcast] Dispatched alert to topic: ${topicName}`);
    } catch (err) {
      console.error(`[FCM Broadcast Error] Failed to broadcast to topic ${topicName}:`, err.message);
    }
  }

  // --- Step B: Target Registered Users Matching Skills ---
  const jobTokens = new Set([
    ...title.toLowerCase().split(/[\s,/-]+/).filter((t) => t.length > 2),
    ...type.toLowerCase().split(/[\s,/-]+/).filter((t) => t.length > 2),
  ]);

  const globalTargetedTokens = new Set();

  try {
    const usersSnapshot = await admin.firestore().collection("users").get();

    for (const doc of usersSnapshot.docs) {
      const user = doc.data();
      const userSkills = Array.isArray(user.skills)
        ? user.skills.map((s) => String(s).toLowerCase().trim())
        : [];
      const userToken = user.fcmToken;
      const userPhone = user.phone;

      // Check for skill intersection
      const isMatch = userSkills.some((skill) =>
        jobTokens.has(skill) || title.toLowerCase().includes(skill)
      );

      if (isMatch) {
        if (userToken && userToken.length > 20 && !globalTargetedTokens.has(userToken)) {
          globalTargetedTokens.add(userToken);
          try {
            await admin.messaging().send({
              token: userToken,
              notification: {
                title: `Matched Job Alert: ${title}`,
                body: `Hello ${user.name || "Candidate"}, an overseas opening matching your skills is open now!`,
              },
              data: {
                title: `Matched Job Alert: ${title}`,
                body: `Hello ${user.name || "Candidate"}, an overseas opening matching your skills is open now!`,
                jobId: String(jobId),
                jobTitle: String(title),
                url: String(defaultJobUrl),
                click_action: String(defaultJobUrl),
                tag: String(jobTag),
              },
              webpush: {
                headers: { Urgency: "high", Topic: jobTag },
                notification: {
                  title: `Matched Job Alert: ${title}`,
                  body: `Hello ${user.name || "Candidate"}, an overseas opening matching your skills is open now!`,
                  icon: "https://avmglobalconsultants.com/icons/Icon-192.png",
                  tag: jobTag,
                  renotify: false,
                },
                fcmOptions: {
                  link: defaultJobUrl,
                },
              },
            });
            console.log(`[Targeted Push] Sent match notification to registered user: ${doc.id}`);
          } catch (fcmError) {
            console.warn(`[Targeted Push Warn] FCM token invalid or expired for user ${doc.id}`);
          }
        }

        // SMS fallback/outreach if candidate provided phone number
        if (userPhone && userPhone.length >= 7) {
          const smsMessage = `AVM Global Job Alert: New opening for ${title} at ${location}. Apply online: ${defaultJobUrl}`;
          await sendTwilioSms(userPhone, smsMessage);
        }
      }
    }
  } catch (userQueryErr) {
    console.error("[Users Query Error] Failed matching registered users:", userQueryErr);
  }

  // --- Step C: Target Direct Applicants Matching Category/Job ---
  try {
    const applicantsSnapshot = await admin.firestore().collection("applicants").get();

    for (const doc of applicantsSnapshot.docs) {
      const applicant = doc.data();
      const category = (applicant.jobCategory || applicant.jobTitle || "").toLowerCase();
      const applicantToken = applicant.fcmToken;
      const applicantPhone = applicant.applicantPhone;

      const isCategoryMatch =
        category.length > 2 &&
        (title.toLowerCase().includes(category) ||
          Array.from(jobTokens).some((token) => category.includes(token)));

      if (isCategoryMatch) {
        if (applicantToken && applicantToken.length > 20 && !globalTargetedTokens.has(applicantToken)) {
          globalTargetedTokens.add(applicantToken);
          try {
            await admin.messaging().send({
              token: applicantToken,
              notification: {
                title: `New Position in your Field: ${title}`,
                body: `A new ${title} position matching your profile is now open at ${company}.`,
              },
              data: {
                title: `New Position in your Field: ${title}`,
                body: `A new ${title} position matching your profile is now open at ${company}.`,
                jobId: String(jobId),
                jobTitle: String(title),
                url: String(defaultJobUrl),
                click_action: String(defaultJobUrl),
                tag: String(jobTag),
              },
              webpush: {
                headers: { Urgency: "high", Topic: jobTag },
                notification: {
                  title: `New Position in your Field: ${title}`,
                  body: `A new ${title} position matching your profile is now open at ${company}.`,
                  icon: "https://avmglobalconsultants.com/icons/Icon-192.png",
                  tag: jobTag,
                  renotify: false,
                },
                fcmOptions: {
                  link: defaultJobUrl,
                },
              },
            });
            console.log(`[Targeted Push] Sent match notification to applicant: ${doc.id}`);
          } catch (fcmErr) {
            console.warn(`[Targeted Push Warn] FCM error for applicant ${doc.id}`);
          }
        }

        if (applicantPhone && applicantPhone.length >= 7) {
          const smsText = `AVM Global Careers: New opening for ${title} matching your profile. Apply at: ${defaultJobUrl}`;
          await sendTwilioSms(applicantPhone, smsText);
        }
      }
    }
  } catch (appQueryErr) {
    console.error("[Applicants Query Error] Failed matching direct applicants:", appQueryErr);
  }

  // --- Step D: Target Search Subscriptions (Anonymous Visitors who Allowed Alerts) ---
  // Note: Only dispatch direct unicast token message if the subscription query was NOT covered by topic broadcast
  try {
    const searchSubsSnapshot = await admin.firestore().collection("search_subscriptions").get();

    for (const doc of searchSubsSnapshot.docs) {
      const sub = doc.data();
      const rawQuery = (sub.rawQuery || "").toLowerCase().trim();
      const topic = sub.topic || "";
      const token = sub.fcmToken;

      const cleanTopicKey = topic.replace(/^job_search_/, "");
      const isAlreadyCoveredByTopic = dispatchedTopics.has(topic) || topicKeywords.has(cleanTopicKey) || cleanTopicKey === "all";

      // If already broadcasted to that topic, skip individual unicast to avoid double notifications
      if (isAlreadyCoveredByTopic) {
        continue;
      }

      const isCustomQueryMatch =
        rawQuery.length >= 2 &&
        (title.toLowerCase().includes(rawQuery) ||
          rawQuery.includes(title.toLowerCase()) ||
          Array.from(jobTokens).some((t) => rawQuery.includes(t) || t.includes(rawQuery)));

      if (isCustomQueryMatch && token && token.length > 20 && !globalTargetedTokens.has(token)) {
        globalTargetedTokens.add(token);
        const subQuery = sub.rawQuery || title;
        const subJobUrl = `${baseUrl}/jobs?query=${encodeURIComponent(subQuery)}&id=${encodeURIComponent(jobId)}`;

        try {
          await admin.messaging().send({
            token: token,
            notification: {
              title: `Job Alert: ${title}`,
              body: `New opening matching your search for "${subQuery}" at ${company} (${location})!`,
            },
            data: {
              title: `Job Alert: ${title}`,
              body: `New opening matching your search for "${subQuery}" at ${company} (${location})!`,
              jobId: String(jobId),
              jobTitle: String(title),
              url: String(subJobUrl),
              click_action: String(subJobUrl),
              tag: String(jobTag),
            },
            webpush: {
              headers: { Urgency: "high", Topic: jobTag },
              notification: {
                title: `Job Alert: ${title}`,
                body: `New opening matching your search for "${subQuery}" at ${company} (${location})!`,
                icon: "https://avmglobalconsultants.com/icons/Icon-192.png",
                tag: jobTag,
                renotify: false,
              },
              fcmOptions: {
                link: subJobUrl,
              },
            },
          });
          console.log(`[Targeted Search Push] Dispatched search alert to token: ${doc.id}`);
        } catch (fcmErr) {
          console.warn(`[Search Push Warn] FCM error for search subscription ${doc.id}:`, fcmErr.message);
        }
      }
    }
  } catch (searchSubErr) {
    console.error("[Search Subscriptions Query Error]:", searchSubErr);
  }

  console.log(`Successfully completed notification dispatch for job: ${jobId}`);
});

// 4. Backend Topic Subscription Trigger
// Automatically registers browser FCM tokens to FCM Topics when saved to Firestore
exports.onSearchSubscriptionCreated = onDocumentCreated("search_subscriptions/{docId}", async (event) => {
  const data = event.data?.data();
  if (!data || !data.fcmToken || data.fcmToken.length < 20 || !data.topic) {
    return;
  }

  try {
    await admin.messaging().subscribeToTopic([data.fcmToken], data.topic);
    console.log(`[Topic Subscription] Successfully subscribed token ${data.fcmToken.substring(0, 10)}... to topic ${data.topic}`);
  } catch (err) {
    console.warn(`[Topic Subscription Warn] Failed subscribing token to ${data.topic}:`, err.message);
  }
});

// Helper for Job Inquiry Emails
function getJobInquiryHtml(recipientName, jobTitle, company, location, customMessage) {
  const contactGreeting = recipientName && recipientName.trim() ? `Dear ${recipientName.trim()},` : "Dear Hiring Team / Employer,";
  const formattedCustomMessage = customMessage
    ? customMessage.replace(/\n/g, "<br/>")
    : `<p style="margin: 0 0 12px 0;">Could you please confirm if this position is <strong>still open and actively accepting candidate profiles</strong>?</p>
       <p style="margin: 0;">If the role has already been filled or is no longer active, please let us know so we can update our candidate records accordingly.</p>`;

  return `
<div style="font-family: 'Segoe UI', Arial, sans-serif; max-width: 600px; margin: 0 auto; background-color: #ffffff; border: 1px solid #e2e8f0; border-radius: 12px; overflow: hidden;">
  <div style="background: linear-gradient(135deg, #0A192F 0%, #146EB8 100%); padding: 24px 24px; text-align: center; color: #ffffff;">
    <h1 style="margin: 0 0 6px 0; font-size: 20px; font-weight: 700; color: #ffffff;">AVM Global Consultants</h1>
    <p style="margin: 0; font-size: 13px; color: #e2e8f0;">Government-Approved Overseas Placement & Manpower Recruitment</p>
  </div>
  <div style="padding: 28px 24px; color: #1e293b;">
    <div style="display: inline-block; background-color: #fef3c7; color: #92400e; font-weight: 600; font-size: 12px; padding: 4px 12px; border-radius: 16px; margin-bottom: 16px;">
      Position Status Inquiry
    </div>
    <h2 style="font-size: 17px; color: #0f172a; margin: 0 0 14px 0;">${contactGreeting}</h2>
    <p style="font-size: 14px; line-height: 1.6; color: #334155; margin: 0 0 16px 0;">
      Greetings from <strong>AVM Global Consultants</strong>.
    </p>
    <p style="font-size: 14px; line-height: 1.6; color: #334155; margin: 0 0 16px 0;">
      We are reaching out to follow up on the following job opening registered with us:
    </p>
    <div style="background-color: #f8fafc; border: 1px solid #e2e8f0; border-radius: 8px; padding: 16px; margin-bottom: 20px;">
      <p style="margin: 0; font-size: 13px; color: #475569;"><strong>Position:</strong> ${jobTitle || "Job Opening"}</p>
    </div>
    <div style="font-size: 14px; line-height: 1.6; color: #334155; margin: 0 0 20px 0;">
      ${formattedCustomMessage}
    </div>
    <p style="font-size: 14px; line-height: 1.6; color: #334155; margin: 0;">
      Thank you for your time and collaboration.<br/><br/>
      Warm regards,<br/>
      <strong>Recruitment & Placement Team</strong><br/>
      <strong>AVM Global Consultants</strong><br/>
      <span style="font-size: 12px; color: #64748b;">Email: vishal@avmglobalconsultants.com | Website: <a href="https://avmglobalconsultants.com" style="color: #146EB8; text-decoration: none;">avmglobalconsultants.com</a></span>
    </p>
  </div>
  <div style="background-color: #f1f5f9; padding: 14px 24px; text-align: center; font-size: 12px; color: #64748b; border-top: 1px solid #e2e8f0;">
    &copy; ${new Date().getFullYear()} AVM Global Consultants. All rights reserved.
  </div>
</div>
`;
}

function getJobInquiryText(recipientName, jobTitle, company, location, customMessage) {
  const contactGreeting = recipientName && recipientName.trim() ? `Dear ${recipientName.trim()},` : "Dear Hiring Team / Employer,";
  if (customMessage) {
    return `${contactGreeting}

${customMessage}

Best regards,
Recruitment & Placement Team
AVM Global Consultants
Email: vishal@avmglobalconsultants.com
Website: https://avmglobalconsultants.com`;
  }

  return `${contactGreeting}

Greetings from AVM Global Consultants.

We are writing to follow up regarding the position of "${jobTitle}" at your company.

Could you kindly let us know if this position is still open and actively accepting candidate applications?

If the position has already been filled or is no longer active, please let us know so we can update our candidate pipeline accordingly.

Thank you for your time.

Best regards,
Recruitment & Placement Team
AVM Global Consultants
Email: vishal@avmglobalconsultants.com
Website: https://avmglobalconsultants.com`;
}

// 5. Automatic Firestore Trigger on Job Inquiry Creation
exports.onJobInquiryCreated = onDocumentCreated("job_inquiries/{docId}", async (event) => {
  const data = event.data?.data();
  if (!data) return;

  const recipientEmail = data.recipientEmail;
  const recipientName = data.recipientName || "";
  const jobTitle = data.jobTitle || "Job Position";
  const company = data.company || "";
  const location = data.location || "";
  const customMessage = data.message || "";

  if (!recipientEmail) {
    console.log("No recipient email found in job_inquiries document");
    return;
  }

  try {
    const mailOptions = {
      from: '"AVM Global Consultants" <vishal@avmglobalconsultants.com>',
      replyTo: "vishal@avmglobalconsultants.com",
      to: recipientEmail,
      subject: `Inquiry: Is the position "${jobTitle}" still open? | AVM Global Consultants`,
      text: getJobInquiryText(recipientName, jobTitle, company, location, customMessage),
      html: getJobInquiryHtml(recipientName, jobTitle, company, location, customMessage),
    };

    const info = await transporter.sendMail(mailOptions);
    console.log(`Job inquiry email sent to ${recipientEmail}. Message ID: ${info.messageId}`);

    await event.data.ref.update({
      emailSent: true,
      sentAt: admin.firestore.FieldValue.serverTimestamp(),
      messageId: info.messageId,
    });
  } catch (error) {
    console.error("Error sending job inquiry email via Firestore trigger:", error);
    try {
      await event.data.ref.update({
        emailSent: false,
        error: error.message,
      });
    } catch (_) {}
  }
});

// 6. Direct HTTPS Endpoint for Job Inquiry Email
exports.sendJobInquiryEmail = onRequest({ cors: true }, async (req, res) => {
  cors(req, res, async () => {
    if (req.method !== "POST") {
      return res.status(405).json({ error: "Method Not Allowed" });
    }

    const {
      recipientEmail,
      recipientName,
      jobTitle,
      company,
      location,
      customMessage,
    } = req.body;

    if (!recipientEmail) {
      return res.status(400).json({ error: "Recipient email is required" });
    }

    try {
      const mailOptions = {
        from: '"AVM Global Consultants" <vishal@avmglobalconsultants.com>',
        replyTo: "vishal@avmglobalconsultants.com",
        to: recipientEmail,
        subject: `Inquiry: Is the position "${jobTitle || "Job Opening"}" still open? | AVM Global Consultants`,
        text: getJobInquiryText(recipientName || "", jobTitle || "Job Position", company || "", location || "", customMessage),
        html: getJobInquiryHtml(recipientName || "", jobTitle || "Job Position", company || "", location || "", customMessage),
      };

      const info = await transporter.sendMail(mailOptions);
      console.log(`Job inquiry email sent directly via HTTPS to ${recipientEmail}. Message ID: ${info.messageId}`);
      return res.status(200).json({ success: true, messageId: info.messageId });
    } catch (error) {
      console.error("Error sending job inquiry email via HTTPS endpoint:", error);
      return res.status(500).json({ error: error.message });
    }
  });
});

// 7. Test Push Notification Endpoint for Isolated Verification
exports.sendTestPushNotification = onRequest({ cors: true }, async (req, res) => {
  cors(req, res, async () => {
    try {
      let { token, title, body, url, delaySeconds } = req.body || {};

      if (!token) {
        const subSnap = await admin.firestore().collection("search_subscriptions").orderBy("subscribedAt", "desc").limit(1).get();
        if (!subSnap.empty) {
          token = subSnap.docs[0].data().fcmToken;
        }
      }

      if (!token) {
        return res.status(400).json({ error: "No active FCM token found to send test notification." });
      }

      if (delaySeconds && Number(delaySeconds) > 0) {
        await new Promise((resolve) => setTimeout(resolve, Number(delaySeconds) * 1000));
      }

      const notifTitle = title || "Test Alert | AVM Global Consultants";
      const notifBody = body || "Test push notification successful! Tap here to view open job positions.";
      const targetUrl = url || "https://avmglobalconsultants.com/jobs";

      const testTag = `test_${Date.now()}`;
      const messagePayload = {
        token: token,
        notification: {
          title: notifTitle,
          body: notifBody,
        },
        data: {
          title: notifTitle,
          body: notifBody,
          url: targetUrl,
          click_action: targetUrl,
          tag: testTag,
        },
        webpush: {
          headers: { Urgency: "high", Topic: testTag },
          notification: {
            title: notifTitle,
            body: notifBody,
            icon: "https://avmglobalconsultants.com/icons/Icon-192.png",
            tag: testTag,
            renotify: false,
          },
          fcmOptions: {
            link: targetUrl,
          },
        },
      };

      const response = await admin.messaging().send(messagePayload);
      console.log("[Test Push] Dispatched successfully:", response);
      return res.status(200).json({
        success: true,
        messageId: response,
        tokenTarget: token.substring(0, 15) + "...",
      });
    } catch (err) {
      console.error("[Test Push Error]:", err);
      return res.status(500).json({ error: err.message });
    }
  });
});


