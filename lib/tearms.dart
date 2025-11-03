import 'package:flutter/material.dart';
import 'package:buntsmatrimony/lang.dart';

class TermsAndConditionsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var localizations = AppLocalizations.of(context);
    Color appcolor = Color(0xFF8A2727);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: appcolor,
        title: Text(
          localizations.translate('terms'),
          style: TextStyle(color: Colors.white), // Set text color to white
        ),
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Container(
            margin: EdgeInsets.fromLTRB(10, 5, 0, 10),
            // decoration: BoxDecoration(
            //   color: Colors.white,
            //   borderRadius: BorderRadius.circular(20),
            // ),
            child: Icon(
              Icons.arrow_back_rounded,
              color: Colors.white,
              size: 25,
            ), // Back button icon
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Text('''
The BuntsMatrimony services (BuntsMatrimony.com) 
   Welcome to BuntsMatrimony.com. In order to use the BuntsMatrimony.com Site ("Site"), you must Register as a member of the Site ("Member") and agree to be bound by these Terms of Use ("Agreement"). If you wish to become a Member and communicate with other Members and make use of the service ("Service"), read these Terms of Use and follow the instructions in the Registration process. By becoming a registered Member, completing the online registration process and checking the box "I have read and understand the Terms of Use and agree to be bound by all of its terms" on the registration page, and using the Service, you agree to be bound by all of the terms and conditions of this Agreement. This Agreement sets out the legally binding terms for your membership. This Agreement may be modified by BuntsMatrimony.com from time to time effective upon you as a Member. Your continued use of the Site pursuant to such change will constitute deemed acceptance of such changes.

1. Eligibility.

The use the Services, you must be the age of majority in your jurisdiction of residence and able to form a binding legal agreement. Specifically, to be eligible to use the Services, you must meet the following criteria and represent and, by agreeing to these Terms of Use, warrant that you:

a) are at least the age of majority in your jurisdiction of residence;
b) are not currently restricted from using the Services, or not otherwise prohibited from having a BuntsMatrimony.com account,
c) are not a competitor of BuntsMatrimony.com or are not using the Services for reasons that are in competition with BuntsMatrimony.com;
d) will only maintain one BuntsMatrimony.com account at any given time;
e) have full right, power authority and legal authority to enter into this Agreement and to abide by all terms and conditions of this Agreement;
f) will not violate any rights of BuntsMatrimony.com other users or of third parties, including intellectual property rights and privacy rights;
g) agree to provide at your cost all equipment, software, and internet access necessary to use the Services;
h) agree to use your first name and your email address when registering. This site is not meant to encourage and/or promote illicit sexual relations or extra marital affairs. If BuntsMatrimony.com discovers or becomes aware that any member is using this site to promote or engage or indulge in illicit sexual relations or extra marital affairs his/her membership will be terminated forthwith without any refund and without any liability to BuntsMatrimony.com. The discretion of BuntsMatrimony.com to terminate shall be final and binding.

2. Password Use and Security

You must not reveal your password and must take reasonable steps to keep your password confidential and secure. You agree to immediately notify BuntsMatrimony.com if you become aware of or have reason to believe that there is any unauthorised use of your password or account or any other breach of security. BuntsMatrimony.com is in no way liable for any claims or losses related to the use or misuse of your password or account due to the activities of any third party outside of our control or due to your failure to maintain their confidentiality and security.

3. User Account Responsibilities.

To use or access certain Services, you must register for and be granted by us an account with BuntsMatrimony.com. You agree to: a) keep your password secure and confidential; b) not permit others to use your account; c) refrain from using other users’ accounts; d) refrain from selling, trading, or otherwise transferring your BuntsMatrimony.com account to another party; and e) refrain from charging anyone for access to the Services. Further, you are responsible for anything that happens through your account until you close it down or prove that your account security was compromised through no fault of your own. You agree to be responsible for any act or omission of any users that access the Services under your account or using your password that, if undertaken by you, would be a violation of these Terms of Use, and that such act or omission shall be deemed a violation of these Terms of Use.

4. Grant of License

As a registered user of a Service, BuntsMatrimony.com grants to you a non-transferable, non-exclusive and revocable license to use the Service according to the terms and conditions set forth in this Agreement. Except as expressly granted by this Agreement or otherwise by BuntsMatrimony.com or its licensors in writing, you acquire no right, title or license in the Service or any data, content, application or materials accessed from or incorporated in the Service.

5. Services.

The Services provide a platform and mechanism for enabling you to connect and connect with the other Members. BuntsMatrimony.com does not participate in the interaction between you and Members and does not have control over the quality, reliability, timing, legality, integrity, authenticity, accuracy, appropriateness, provision, or failure to provide, or responsiveness of the information provided by or to the other Members, and does not monitor or control whether any participant, including registered users and/or visitors to the Site, are who they claim to be. BuntsMatrimony.com makes no representations about any of these and assumes no responsibility for any of them as more fully set forth below. BuntsMatrimony.com does not recommend or endorse any specific bride or bridegroom listed on the website or any other information regarding them that may be mentioned through Services.

6. Terms.

This Agreement will remain in full force and effect while you use the Site and/or are a Member of BuntsMatrimony.com. You may terminate your membership at any time, for any reason by informing BuntsMatrimony.com in writing to terminate your Membership. In the event you terminate your membership, you will not be entitled to a refund of any unutilised subscription fees. BuntsMatrimony.com may terminate your access to the Site and/or your membership for any reason which shall be effective upon sending notice of termination to you at the email address you provide in your application for membership or such other email address as you may later provide to BuntsMatrimony.com. If BuntsMatrimony.com terminates your membership because of a breach of the Agreement by you, you will not be entitled to any refund of any unused Subscription fees. Even after this Agreement is terminated, certain provisions will remain in effect including sections 8,9,11,13 -16, inclusive, of this Agreement.

7. Non-Commercial Use by Members.

The BuntsMatrimony.com Site is for the personal use of individual members only, and may not be used in connection with any commercial endeavours. This includes providing links to other websites, whether deemed competitive to BuntsMatrimony.com or otherwise. Organisations, companies, and/or businesses may not become Members of BuntsMatrimony.com and should not use the BuntsMatrimony.com Service or Site for any purpose. Illegal and/or unauthorised uses of the Site, including unauthorised framing of or linking to the Site will be investigated, and appropriate legal action will be taken, including without limitation, civil, criminal, and injunctive redress.

8. Other Terms of Use by Members.

You may not engage in advertising to, or solicitation of, other Members to buy or sell any products or services through the Service. You will not transmit any chain letters or junk email to other BuntsMatrimony.com Members. Although BuntsMatrimony.com cannot monitor the conduct of its Members on the BuntsMatrimony.com Site, it is also a violation of this Agreement to use any information obtained from the Service in order to harass, abuse, or harm another person, or in order to contact, advertise to, solicit, or sell to any Member without their prior explicit consent. In order to protect BuntsMatrimony.com and/or our Members from any abuse/misuse, BuntsMatrimony.com reserves the right to restrict the number of communications/profile contacts & responses/emails which a Member may send to other Member(s) in any 24-hour period to a number which BuntsMatrimony.com deems appropriate in its sole discretion. You will not send any messages to other Members that are obscene, lewd, licentious, and defamatory, promote hatred and/or are racial or abusive in any manner. Transmission of any such messages shall constitute a breach of this Agreement and BuntsMatrimony.com shall be entitled to terminate your membership forthwith. BuntsMatrimony.com reserves the right to screen messages that you may send to other Member(s) and also regulate the number of your chat sessions in its sole discretion.

You may not use any automated processes, including IRC Bots, EXE's, CGI or any other programs/scripts to view content on or communicate/contact/respond/interact with BuntsMatrimony.com and/or its Members.

9. Content Posted on the Site.

BuntsMatrimony.com owns and retains all proprietary rights, including without limitation, all intellectual property rights in the BuntsMatrimony.com Site and the BuntsMatrimony.com Service. The Site contains the copyrighted material, trademarks, and other proprietary information of BuntsMatrimony.com, and its licensors. Except for that information which is in the public domain or for which you have been given express permission by BuntsMatrimony.com, you may not copy, modify, publish, transmit, distribute, perform, display, or sell any such proprietary information. All lawful, legal and non-objectionable messages (in the sole discretion of BuntsMatrimony.com), content and/or other information, content or material that you post on the forum boards shall become the property of BuntsMatrimony.com. BuntsMatrimony.com reserves the right to scrutinise all such information, content and/or material posted on the forum boards and shall have the exclusive right to either remove, edit and/or display such information, material and/or content. You understand and agree that BuntsMatrimony.com may delete any content, messages, photos or profiles (collectively, "Content") that in the sole judgment of BuntsMatrimony.com violates this Agreement or which might be offensive, illegal, defamatory, obscene, libelous, or that might violate the rights, harm, or threaten the safety of other BuntsMatrimony.com Members.

You are solely responsible for the Content that you publish or display (hereinafter, "post") on the Site through the BuntsMatrimony.com Service, or transmit to other BuntsMatrimony.com Members. BuntsMatrimony.com reserves the right to verify the authenticity of Content posted on the Site. In exercising this right, BuntsMatrimony.com may ask you to provide any documentary or other form of evidence supporting the Content you post on the Site. If you fail to produce such evidence, or if such evidence does not in the reasonable opinion of BuntsMatrimony.com establish or justify the claim, BuntsMatrimony.com may, in its sole discretion, terminate your Membership without a refund of your subscription fees

By posting Content to any public area of BuntsMatrimony.com , you automatically grant, and you represent and warrant that you have the right to grant, to BuntsMatrimony.com , and other BuntsMatrimony.com Members, an irrevocable, perpetual, non-exclusive, fully-paid, worldwide unlimited, assignable, sub-licenseable, fully paid-up and royalty-free right to use, copy, perform, publish, display, and distribute such information and content and to prepare derivative works of, improve, remove, retain, add, process, analyse, use and commercialise, in any way now known or in the future discovered, the information you provide, directly or indirectly to BuntsMatrimony.com, including, without limitation, user-generated content, ideas, concepts, techniques and/or data, or incorporate into other works, such information and content, and to grant and authorise sublicensees of the foregoing. Any information you submit to us is at your own risk of loss.

The following is a partial list of the kind of Content that is illegal or prohibited on the Site. BuntsMatrimony.com will investigate and take appropriate legal action in its sole discretion against anyone who violates this provision, including without limitation, removing the offending communication from the Service and the Site and terminating the Membership of such violators without a refund. It includes (but is not limited to) Content that:

Newly created profile will be checked for correctness and will be immediately activated after quality declaration is verified by BuntsMatrimony.com.

BuntsMatrimony.com reserves the rights to discontinue, deactivate, or terminate profile if the profile is in terms of bad manners and the profile contents are not acceptable if it contains violent language or wrong material.

You are only liable for your connections with other members through BuntsMatrimony.com.

Contact information of member’s profile will display only to paid members. Members agree that they are legally eligible to get married as far as the age is concerned. BuntsMatrimony.com will not be responsible for misuse of any facility/service it provides, which is in violation of the local government laws.

Every member submitting his/her matrimonial profile is required to give all the facts essential for establishing a marital relation. Concealing facts relevant to marriage could result in loss or damage to any individual and BuntsMatrimony.com shall not be held responsible in any manner for such concealment.

BuntsMatrimony.com in no way guarantees the genuineness of the information provided by its members.

Members will not have any claim against BuntsMatrimony.com for any time delay in posting their information into BuntsMatrimony.com website due to any technical reasons.

BuntsMatrimony.com is not liable for damages caused due to incorrectness of the information provided by its members regarding the religion, caste or creed, financial or any other personal information. If the members’ profile is deemed to be unfit, BuntsMatrimony.com has the right to delete, alter or refuse the same at any point of time without any notice.

BuntsMatrimony.com cannot be held responsible for any loss or damage resulting from discontinuation of the service. BuntsMatrimony.com will also not be responsible for any damage caused due to others accessing members’ profile.

BuntsMatrimony.com cannot guarantee that you as an applicant will receive responses and hence BuntsMatrimony.com shall not be held responsible for no replies. In this case where the member fails to get any response from other members, BuntsMatrimony.com shall not give any refunds or credits.

BuntsMatrimony.com is not legally responsible for any delay in operation due to technical or other reasons.

Harasses or advocates harassment of another person;

Involves the transmission of "junk mail", "chain letters," or unsolicited mass mailing or "spamming";

Promotes information that the person posting it is aware that it is false, misleading or promotes illegal activities or conduct that is abusive, threatening, obscene, defamatory or libellous;

Promotes an illegal or unauthorised copy of another person's copyrighted work, such as providing pirated computer programs or links to them, providing information to circumvent manufacture-installed copy-protect devices, or providing pirated music or links to pirated music files;

Contains restricted or password only access pages, or hidden pages or images (those not linked to or from another accessible page);

Displays pornographic or sexually explicit material of any kind;

Provides material that exploits people who are minors as per the jurisdiction of their residence in a sexual or violent manner, or solicits personal information from such minors;

Provides instructional information about illegal activities such as making or buying illegal weapons, violating someone's privacy, or providing or creating computer viruses;

Solicits passwords or personal identifying information for commercial or unlawful purposes from other users / Members; and

Engages in commercial activities and/or sales without the prior written consent of BuntsMatrimony.com such as contests, sweepstakes, barter, advertising, and pyramid schemes.

Encourages, invites or solicits extra marital affairs.

You must use the BuntsMatrimony.com Service in a manner consistent with any and all applicable local, state, and federal laws and regulations.

You are not permitted to create multiple profiles. If BuntsMatrimony.com is aware that you have created multiple profiles, your membership will be liable to be terminated forthwith without any refund of subscription fees.

If at any time BuntsMatrimony.com is of the view in its sole discretion that your profile contains any information or material or content which is objectionable, unlawful or illegal, BuntsMatrimony.com has the right in its sole discretion to either forthwith terminate your membership without refund of your subscription fees or delete such objectionable, illegal or unlawful information, material or content from your profile and allow you to continue as a Member.



10. Copyright Policy.

You may not post, distribute, or reproduce in any way any copyrighted material, trademarks, or other proprietary information without obtaining the prior written consent of the owner of such proprietary rights. Without limiting the foregoing, if you believe that your work has been copied and posted on the Site through the BuntsMatrimony.com Service in a way that constitutes copyright infringement, please provide our Copyright Agent with the following information: an electronic or physical signature of the person authorised to act on behalf of the owner of the copyright interest; a description of the copyrighted work that you claim has been infringed; a description of where the material that you claim is infringing is located on the Site; your address, telephone number, and email address; a written statement by you that you have a good faith belief that the disputed use is not authorised by the copyright owner, its agent, or the law; and where applicable a copy of the registration certificate proving registration of copyright or any other applicable intellectual property right; a statement by you, made under penalty of perjury, that the above information in your Notice is accurate and that you are the copyright owner or authorised to act on the copyright owner's behalf. BuntsMatrimony.com's Copyright Agent for Notice of claims of copyright infringement can be reached by writing to the Bangalore address located under the Help/Contact section on the site.

11. Member Disputes.

You are solely responsible for your interactions with other BuntsMatrimony.com Members. BuntsMatrimony.com reserves the right, but has no obligation, to monitor disputes between you and other Members.

12. Privacy.

Use of the BuntsMatrimony.com Site and/or the BuntsMatrimony.com Service is governed by the BuntsMatrimony.com Privacy Policy.

13. Disclaimers.

BuntsMatrimony.com is not responsible for any incorrect or inaccurate Content posted on the Site or in connection with the BuntsMatrimony.com Service, whether caused by users visiting the Site, Members or by any of the equipment or programming associated with or utilised in the Service, nor for the conduct of any user and/or Member of the BuntsMatrimony.com Service whether online or offline. BuntsMatrimony.com assumes no responsibility for any error, omission, interruption, deletion, defect, delay in operation or transmission, communications line failure, theft or destruction or unauthorised access to, or alteration of, user and/or Member communications. BuntsMatrimony.com is not responsible for any problems or technical malfunction of any telephone network or lines, computer on-line-systems, servers or providers, computer equipment, software, failure of email or players on account of technical problems or traffic congestion on the Internet or at any website or combination thereof, including injury or damage to users and/or Members or to any other person's computer related to or resulting from participating or downloading materials in connection with the BuntsMatrimony.com Site and/or in connection with the BuntsMatrimony.com Service. Under no circumstances will BuntsMatrimony.com be responsible for any loss or damage to any person resulting from anyone's use of the Site or the Service and/or any Content posted on the BuntsMatrimony.com Site or transmitted to BuntsMatrimony.com Members. The exchange of profile(s) through or by BuntsMatrimony.com should not in any way be construed as any offer, endorsement and/or recommendation from/by BuntsMatrimony.com. BuntsMatrimony.com shall not be responsible for any loss or damage to any individual arising out of, or subsequent to, relations established pursuant to the use of BuntsMatrimony.com. The Site and the Service are provided "AS-IS AVAILABLE BASIS" and BuntsMatrimony.com expressly disclaims any warranty of fitness for a particular purpose or non-infringement. BuntsMatrimony.com cannot guarantee and does not promise any specific results from use of the Site and/or the BuntsMatrimony.com Service.

14. Limitation on Liability.

Except in jurisdictions where such provisions are restricted, in no event will BuntsMatrimony.com be liable to you or any third person for any indirect, consequential, exemplary, incidental, special or punitive damages, including also lost profits arising from your use of the Site or the BuntsMatrimony.com Service, even if BuntsMatrimony.com has been advised of the possibility of such damages. Notwithstanding anything to the contrary contained anywhere in this Agreement, the total aggregate liability of BuntsMatrimony.comunder this Agreement for any cause whatsoever, and regardless of the form of the action, shall at all times be limited to the amount paid, if any, by you to BuntsMatrimony.com, for the Service during the term of membership.

15. Disputes.

If there is any dispute about or involving the Site and/or the Service, by using the Site, you agree that the dispute will be governed by the laws of India. You agree to the exclusive jurisdiction to the courts of Bangalore, India.

16. Indemnity.

You agree to indemnify and hold BuntsMatrimony.com, its subsidiaries, directors, affiliates, officers, agents, and other partners and employees, harmless from any loss, liability, claim, or demand, including reasonable attorney's fees, made by any third party due to or arising out of your use of the Service in violation of this Agreement and/or arising from a breach of these Terms of Use and/or any breach of your representations and warranties set forth above or any third party liability in relation to any Content or post provided by you pursuant to this Agreement.

17. Others.

By becoming a Member of the Site / BuntsMatrimony.com Service, you agree to receive certain specific emails from BuntsMatrimony.com.

This Agreement, accepted upon use of the Site and further affirmed by becoming a Member of the BuntsMatrimony.com Service, contains the entire agreement between you and BuntsMatrimony.com regarding the use of the Site and/or the Service. If any provision of this Agreement is held invalid, the remainder of this Agreement shall continue in full force and effect.

You are under an obligation to report any misuse or abuse of the Site. If you notice any abuse or misuse of the Site or anything which is in violation of this Agreement, you shall forthwith report such violation to BuntsMatrimony.com by writing to Customer Care. On receipt of such complaint, BuntsMatrimony.com may investigate such complaint and if necessary may terminate the membership of the Member responsible for such violation abuse or misuse without any refund of subscription fee. Any false complaint made by a Member shall make such Member liable for termination of his / her membership without any refund of the subscription fee.

Please contact us with any questions regarding this Agreement.
''', style: TextStyle(fontSize: 16.0)),
        ),
      ),
    );
  }
}
