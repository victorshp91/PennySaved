//
//  PrivacyPolicyView.swift
//  PennySaved
//
//  Created by Victor Saint Hilaire on 10/13/24.
//


import SwiftUI

struct PrivacyPolicyView: View {
    let accentColor = Color(hex: "C9F573")
    let backgroundColor = Color(hex: "0B1523")
    let secondaryColor = Color(hex: "212B33")
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Privacy Policy")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(accentColor)
                
                Group {
                    policySection(title: "Introduction", content: "This privacy policy applies to the ThinkTwiceSave app (hereby referred to as \"Application\") for mobile devices that was created by Victor Saint-Hilaire (hereby referred to as \"Service Provider\") as a Freemium service. This service is intended for use \"AS IS\".")
                    
                    policySection(title: "Information Collection and Use", content: "The Application collects information when you download and use it. This information may include information such as:\n• Your device's Internet Protocol address (e.g. IP address)\n• The pages of the Application that you visit, the time and date of your visit, the time spent on those pages\n• The time spent on the Application\n• The operating system you use on your mobile device\n\nThe Application does not gather precise information about the location of your mobile device.\n\nThe Service Provider may use the information you provided to contact you from time to time to provide you with important information, required notices and marketing promotions.\n\nFor a better experience, while using the Application, the Service Provider may require you to provide us with certain personally identifiable information. The information that the Service Provider request will be retained by them and used as described in this privacy policy.")
                    
                    policySection(title: "Third Party Access", content: "Only aggregated, anonymized data is periodically transmitted to external services to aid the Service Provider in improving the Application and their service. The Service Provider may share your information with third parties in the ways that are described in this privacy statement.\n\nThe Service Provider may disclose User Provided and Automatically Collected Information:\n• as required by law, such as to comply with a subpoena, or similar legal process;\n• when they believe in good faith that disclosure is necessary to protect their rights, protect your safety or the safety of others, investigate fraud, or respond to a government request;\n• with their trusted services providers who work on their behalf, do not have an independent use of the information we disclose to them, and have agreed to adhere to the rules set forth in this privacy statement.")
                    
                    policySection(title: "Opt-Out Rights", content: "You can stop all collection of information by the Application easily by uninstalling it. You may use the standard uninstall processes as may be available as part of your mobile device or via the mobile application marketplace or network.")
                    
                    policySection(title: "Data Retention Policy", content: "The Service Provider will retain User Provided data for as long as you use the Application and for a reasonable time thereafter. If you'd like them to delete User Provided Data that you have provided via the Application, please contact them at victorshp30@gmail.com and they will respond in a reasonable time.")
                    
                    policySection(title: "Children", content: "The Service Provider does not use the Application to knowingly solicit data from or market to children under the age of 13.\n\nThe Service Provider does not knowingly collect personally identifiable information from children. The Service Provider encourages all children to never submit any personally identifiable information through the Application and/or Services. The Service Provider encourage parents and legal guardians to monitor their children's Internet usage and to help enforce this Policy by instructing their children never to provide personally identifiable information through the Application and/or Services without their permission. If you have reason to believe that a child has provided personally identifiable information to the Service Provider through the Application and/or Services, please contact the Service Provider (victorshp30@gmail.com) so that they will be able to take the necessary actions. You must also be at least 16 years of age to consent to the processing of your personally identifiable information in your country (in some countries we may allow your parent or guardian to do so on your behalf).")
                    
                    policySection(title: "Security", content: "The Service Provider is concerned about safeguarding the confidentiality of your information. The Service Provider provides physical, electronic, and procedural safeguards to protect information the Service Provider processes and maintains.")
                    
                    policySection(title: "Changes", content: "This Privacy Policy may be updated from time to time for any reason. The Service Provider will notify you of any changes to the Privacy Policy by updating this page with the new Privacy Policy. You are advised to consult this Privacy Policy regularly for any changes, as continued use is deemed approval of all changes.\n\nThis privacy policy is effective as of 2024-10-14")
                    
                    policySection(title: "Your Consent", content: "By using the Application, you are consenting to the processing of your information as set forth in this Privacy Policy now and as amended by us.")
                    
                    policySection(title: "Contact Us", content: "If you have any questions regarding privacy while using the Application, or have questions about the practices, please contact the Service Provider via email at victorshp30@gmail.com.")
                }
            }
            .padding()
        }
        .background(backgroundColor.edgesIgnoringSafeArea(.all))
        .navigationBarTitle("Privacy Policy", displayMode: .inline)
    }
    
    private func policySection(title: String, content: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(accentColor)
            
            Text(content)
                .foregroundColor(.white)
        }
        .padding()
        .background(secondaryColor)
        .cornerRadius(10)
    }
}

struct PrivacyPolicyView_Previews: PreviewProvider {
    static var previews: some View {
        PrivacyPolicyView()
    }
}