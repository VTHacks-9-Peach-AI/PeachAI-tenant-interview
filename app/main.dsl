// Import the commonReactions library so that you don't have to worry about coding the pre-programmed replies
import "commonReactions/all.dsl";

context
{
    // Declare the input variable - phone. It's your hotel room phone number and it will be used at the start of the conversation.
    input phone: string;
    output new_time: string="";
    output new_day: string="";
}

// A start node that always has to be written out. Here we declare actions to be performed in the node.
start node root
{
    do
    {
        #connectSafe($phone); // Establishing a safe connection to the tenant's phone.
        #waitForSpeech(1000); // Waiting for 1 second to say the welcome message or to let the tenant say something
        #sayText("Hi, my name is Peach, I'm calling in regard to your rental application for 975 Academy Way for Landlord Samir. I'd like to ask you some questions. Is it a good time to talk?"); // Welcome message
        wait *; // Wating for the hotel guest to reply
    }
    transitions // Here you give directions to which nodes the conversation will go
    {
        will_call_back: goto will_call_back on #messageHasIntent("no");
        question1: goto question1 on #messageHasIntent("yes");
    }
}

node will_call_back
{
    do
    {
        #sayText("No worries, when may we call you back?");
        wait *;
    }
    transitions
    {
        call_bye: goto call_bye on #messageHasData("time");
    }
}

node call_bye
{
    do
    {
        set $new_time =  #messageGetData("time")[0]?.value??"";
        #sayText("Got it, I'll call you back on " + $new_time + ". Looking forward to speaking to you soon. Have a nice day!");
        exit;
    }
}

// lines 73-333 are our perfect world flow
node question1
{
    do
    {
        #sayText("Alright, so, let's begin.");
        #sayText("Are you expecting an unfurnished or furnished aparment ? ");
        wait *;
    }
    transitions
    {
        question2: goto question2 on #messageHasIntent("furnished");
        question2part2: goto question2part2 on #messageHasIntent("unfurnished");
    }
}
node question2part2
{
    do
    {
        #sayText("Wonderful! Glad you are okay with an not furnished apartment. Now, could you tell me whether you smoke or not ?");
        wait *;
    }
    transitions
    {
        disqualified: goto disqualified on #messageHasIntent("smoke");
        question3: goto question3 on #messageHasIntent("nosmoke");
    }
}

node question2
{
    do
    {
        #sayText("Wonderful! Glad you are okay with furnished apartment. Now, could you tell me whether you smoke or not ?");
        wait *;
    }
    transitions
    {
        disqualified: goto disqualified on #messageHasIntent("smoke");
        question3: goto question3 on #messageHasIntent("nosmoke");
    }
}

node question3
{
    do
    {
        #sayText("Perfect! Are you willing to get renter's insurance ?");
        wait *;
    }
    transitions
    {
        disqualified: goto disqualified on #messageHasIntent("no");
        renterInsurance: goto renterInsurance on #messageHasIntent("renterInsurance");
        question4: goto question4 on #messageHasIntent("yes");
    }
}

node renterInsurance
{
    do
    {
        #sayText("Renters' insurance, often called tenants' insurance, is an insurance policy that provides some of the benefits of homeowners' insurance, but does not include coverage for the dwelling, or structure, with the exception of small alterations that a tenant makes to the structure. Did you understand?");
        wait *;
    }
    transitions
    {
        question3: goto question3 on #messageHasIntent("yes");
        renterInsurance: goto renterInsurance on #messageHasIntent("renterInsurance");
    }
}

node question4
{
    do
    {
        #sayText("Final question. There are 2 children living in the propery. On a scale of 1 to 10, with 10 being most tolerant how tolerant are you to noise ?");
        wait *;
    }
    transitions
    {
        end_interview: goto end_interview on #messageHasIntent("hightolerance");
        disqualified: goto disqualified on #messageHasIntent("lowtolerance");
    }
}

node end_interview
{
    do
    {
        #sayText("Wonderful! Um... This concludes our call, I will relay your replies to the landlord. If selected, I will contact you again for a viewing of the property. Have a fantastic rest of the day. Bye!");
        exit;
    }
}

node disqualified
{
    do
    {
        #sayText("Thank you so much for letting me know! It saddens me to say that it doesn't match out basic qualification requirements. That being said, we will inform your replies to landlord and contact you once a matching apartment appears. Thank you for your time and have a wonderful day! Bye!");
        exit;
    }
}
