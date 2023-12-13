require 'yaml'

describe 'compiled component route53-zone' do
  
  context 'cftest' do
    it 'compiles test' do
      expect(system("cfhighlander cftest #{@validate} --tests tests/disable_custom_resource.test.yaml")).to be_truthy
    end      
  end
  
  let(:template) { YAML.load_file("#{File.dirname(__FILE__)}/../out/tests/disable_custom_resource/route53-zone.compiled.yaml") }
  
  context "Resource" do

    
    context "HostedZone" do
      let(:resource) { template["Resources"]["HostedZone"] }

      it "is of type AWS::Route53::HostedZone" do
          expect(resource["Type"]).to eq("AWS::Route53::HostedZone")
      end
      
      it "to have property Name" do
          expect(resource["Properties"]["Name"]).to eq({"Fn::Sub"=>"${EnvironmentName}.${RootDomainName}"})
      end
      
      it "to have property HostedZoneConfig" do
          expect(resource["Properties"]["HostedZoneConfig"]).to eq({"Comment"=>{"Fn::Sub"=>"Hosted Zone for ${EnvironmentName}"}})
      end
      
      it "to have property HostedZoneTags" do
          expect(resource["Properties"]["HostedZoneTags"]).to eq([{"Key"=>"Environment", "Value"=>{"Ref"=>"EnvironmentName"}}, {"Key"=>"EnvironmentType", "Value"=>{"Ref"=>"EnvironmentType"}}])
      end
      
    end

    
    context "NSRecords" do
      let(:resource) { template["Resources"]["NSRecords"] }

      it "is of type AWS::Route53::RecordSet" do
          expect(resource["Type"]).to eq("AWS::Route53::RecordSet")
      end
      
      it "to have property HostedZoneName" do
          expect(resource["Properties"]["HostedZoneName"]).to eq({"Ref"=>"RootDomainName"})
      end
      
      it "to have property Comment" do
          expect(resource["Properties"]["Comment"]).to eq({"Fn::Join"=>["", [{"Fn::Sub"=>"${EnvironmentName} - NS Records for ${EnvironmentName}."}, {"Ref"=>"RootDomainName"}]]})
      end
      
      it "to have property Name" do
          expect(resource["Properties"]["Name"]).to eq({"Fn::Sub"=>"${EnvironmentName}.${RootDomainName}"})
      end
      
      it "to have property Type" do
          expect(resource["Properties"]["Type"]).to eq("NS")
      end
      
      it "to have property TTL" do
          expect(resource["Properties"]["TTL"]).to eq(60)
      end
      
      it "to have property ResourceRecords" do
          expect(resource["Properties"]["ResourceRecords"]).to eq({"Fn::GetAtt"=>["HostedZone", "NameServers"]})
      end
      
    end
    
  end

end