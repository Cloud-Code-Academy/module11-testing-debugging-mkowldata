@IsTest
public with sharing class LeadTriggerHandlerTest {
    static void LeadTriggerHandlerTest() {

    }

    @IsTest
    static void testhandleTitleNormalization_title() {
        // Create leads with title to normalize
        List<Lead> leadsToNormalize = new List<Lead>();
        leadsToNormalize.add(new Lead(LastName = 'PlumTree', Company = 'Tree Co', Title = 'vp'));
        leadsToNormalize.add(new Lead(LastName = 'PearTree', Company = 'Tree Co', Title = 'mgr'));
        leadsToNormalize.add(new Lead(LastName = 'PeachTree', Company = 'Tree Co', Title = 'chief'));
        leadsToNormalize.add(new Lead(LastName = 'AppleTree', Company = 'Tree Co', Title = 'deputy'));
        leadsToNormalize.add(new Lead(LastName = 'AppleTree', Company = 'Tree Co', Title = null));
        leadsToNormalize.add(new Lead(LastName = 'AppleTree', Company = 'Tree Co', Title = ''));
        
        // Run TriggerHandler in test for Normalization method
        Test.startTest();
        LeadTriggerHandler.handleTitleNormalization(leadsToNormalize);
        Test.stopTest();
        
        // Return list of created leads
        Lead normalizedLd = leadsToNormalize[0];

        // The expected outcome of the inserted lead
        Assert.areEqual('Vice President', leadsToNormalize[0].Title, 'Title was not updated to Vice President');
        Assert.areEqual('Manager', leadsToNormalize[1].Title, 'Title was not updated to Manager');
        Assert.areEqual('Executive', leadsToNormalize[2].Title, 'Title was not updated to Executive');
        Assert.areEqual('Assistant', leadsToNormalize[3].Title, 'Title was not updated to Assistant');
    }

    @IsTest
    static void testhandleAutoLeadScoring() {
        // Create the test leads
         List<Lead> leadScoring = new List<Lead>();
        leadScoring.add(new Lead(LastName = 'PlumTree', Company = 'Tree Co', LeadSource = 'Web', Phone = '000-111-2222', Industry = 'Technology', Email = 'test@test.com.invalid'));
        leadScoring.add(new Lead(LastName = 'PeachTree', Company = 'Tree Co', LeadSource = 'Web', Phone = '000-111-2222', Industry = 'Technology', Email = null));
        leadScoring.add(new Lead(LastName = 'FruitTree', Company = 'Tree Co', LeadSource = 'Web', Phone = '000-111-2222', Industry = 'Technology', Email = ''));
        leadScoring.add(new Lead(LastName = 'AppleTree', Company = 'Tree Co', LeadSource = 'Web', Phone = '', Industry = 'Technology', Email = 'test@test.com.invalid'));
        leadScoring.add(new Lead(LastName = 'PearTree', Company = 'Tree Co', LeadSource = 'Web', Phone = '000-111-2222', Industry = null, Email = 'test@test.com.invalid'));
        leadScoring.add(new Lead(LastName = 'MangoTree', Company = 'Tree Co', LeadSource = 'Web', Phone = '', Industry = null, Email = 'test@test.com.invalid'));
        leadScoring.add(new Lead(LastName = 'BananaTree', Company = 'Tree Co', LeadSource = 'Other', Phone = '000-222-3333', Industry = 'Banking', Email = 'test@test.com.invalid'));
        leadScoring.add(new Lead(LastName = 'OrangeTree', Company = 'Tree Co', LeadSource = 'Phone Iquiry', Phone = '', Industry = 'Banking', Email = 'test@test.com.invalid'));
        leadScoring.add(new Lead(LastName = 'LimeTree', Company = 'Tree Co', LeadSource = 'Phone Iquiry', Phone = '', Industry = 'Technology', Email = 'test@test.com.invalid'));

        // Run triggerhandler in test for LeadScoring method
        Test.startTest();
        LeadTriggerHandler.handleAutoLeadScoring(leadScoring);
        Test.stopTest();

        // Return the list of leads
        Lead scoredLeads = leadScoring[0];

        // The expected outcome of score
        Assert.areEqual(18, leadScoring[0].Lead_Score__c, 'The Lead Score should be 18');
        Assert.areEqual(15, leadScoring[1].Lead_Score__c, 'The Lead Score should be 15 - email is null');
        Assert.areEqual(15, leadScoring[2].Lead_Score__c, 'The Lead Score should be 15 - email is blank');
        Assert.areEqual(13, leadScoring[3].Lead_Score__c, 'The Lead Score should be 13 - phone is blank');
        Assert.areEqual(8, leadScoring[4].Lead_Score__c, 'The Lead Score should be 8 - industry is not Technology');
        Assert.areEqual(3, leadScoring[5].Lead_Score__c, 'The Lead Score should be 3 - phone and industry are missing or invalid');
        Assert.areEqual(5, leadScoring[6].Lead_Score__c, 'The Lead Score should be 5 - lead source invalid or missing or email is missing and industry is missing or invalid');
        Assert.areEqual(0, leadScoring[7].Lead_Score__c, 'The Lead Score should be 0 - leadsource, email, phone and industry have not qualifying data for scores');
        Assert.areEqual(10, leadScoring[8].Lead_Score__c, 'The Lead Score should be 10 - leadsource, email or phone are invalid or missing');
    }

    @IsTest
    static void testhandleLeadAutoConvert_positive_insert() {
        // Create Account and contact so autoconvert can test against
        //List<Account> newAccts = new List<Account>();
        Account newAcct = new Account(Name = 'CodingBelly Co.');
        insert newAcct;

        //List<Contact> myContacts = new List<Contact>();
        Contact cont = new Contact(LastName = 'Belly', Email = 'test@test.com.invalid', AccountId = newAcct.Id);
        //myContacts.add(cont);
        insert cont;
        
        // Create the test leads
        //List<Lead> leadsToConvert = new List<Lead>();
        Lead leads = new Lead(LastName = 'CodeBelly', Company = 'Coding Co.',  Email = 'test@test.com.invalid');
        //leadsToConvert.add(leads);

        // Run the leadAutoConvertHandler
        Test.startTest();
        insert leads;
        Test.stopTest();

        // Return the list of leads processed
        Lead updatedLead = [SELECT Id, IsConverted FROM Lead WHERE Id = :leads.Id];
        Lead convertedLead = [SELECT ConvertedAccountId, ConvertedContactId FROM Lead WHERE Id = :leads.Id];

        // Assert the lead converted - merged with existing contact if email is the same.
        Assert.areEqual(cont.Id, convertedLead.ConvertedContactId, 'Contact Id does not match');
        Assert.areEqual(newAcct.Id, convertedLead.ConvertedAccountId, 'Account Id does not match');
        Assert.isTrue(updatedLead.IsConverted, 'Lead should be converted');
    }

    @IsTest
    static void testhandleLeadAutoConvert_positive_update() {
        // Create Account and contact so autoconvert can test against
        //List<Account> newAccts = new List<Account>();
        Account newAcct = new Account(Name = 'CodingBelly Co.');
        insert newAcct;

        //List<Contact> myContacts = new List<Contact>();
        Contact cont = new Contact(LastName = 'Belly', Email = 'test@test.com.invalid', AccountId = newAcct.Id);
        //myContacts.add(cont);
        insert cont;
        
        // Create the test leads
        //List<Lead> leadsToConvert = new List<Lead>();
        Lead leads = new Lead(LastName = 'CodeBelly', Company = 'Coding Co.',  Email = 'test@test.com');
        //leadsToConvert.add(leads);
        insert leads;

        Lead updateTheLead = [SELECT Id, Email FROM Lead WHERE Id = :leads.Id];
        updateTheLead.Email = 'test@test.com.invalid';

        // Run the leadAutoConvertHandler
        Test.startTest();
        update updateTheLead;
        Test.stopTest();

        // Return the list of leads processed
        Lead updatedLead = [SELECT Id, IsConverted FROM Lead WHERE Id = :leads.Id];
        Lead convertedLead = [SELECT ConvertedAccountId, ConvertedContactId FROM Lead WHERE Id = :leads.Id];

        // Assert the lead converted - merged with existing contact if email is the same.
        Assert.areEqual(cont.Id, convertedLead.ConvertedContactId, 'Contact Id does not match');
        Assert.areEqual(newAcct.Id, convertedLead.ConvertedAccountId, 'Account Id does not match');
        Assert.isTrue(updatedLead.IsConverted, 'Lead should be converted');
    }

    @IsTest
    static void testhandleLeadAutoConvert_negative() {
        // Create Account and contact so autoconvert can test against
        //List<Account> newAccts = new List<Account>();
        Account newAcct = new Account(Name = 'CodingBelly Co.');
        insert newAcct;

        List<Contact> myContacts = new List<Contact>();
        myContacts.add(new Contact(LastName = 'Belly', Email = 'test@test.com.invalid', AccountId = newAcct.Id));
        myContacts.add(new Contact(LastName = 'CodingBelly', Email = 'test@test.com.invalid', AccountId = newAcct.Id));
        myContacts.add(new Contact(LastName = 'ApexBelly', Email = '', AccountId = newAcct.Id));
        insert myContacts;
        
        // Create the test leads
        //List<Lead> leadsToConvert = new List<Lead>();
        Lead leads = new Lead(LastName = 'CodeBelly', Company = 'Coding Co.',  Email = 'test@test.com.invalid');
        //leadsToConvert.add(leads);

        // Run the leadAutoConvertHandler
        Test.startTest();
        insert leads;
        Test.stopTest();

        // Return the list of leads processed
        Lead updatedLead = [SELECT Id, IsConverted FROM Lead WHERE Id = :leads.Id];
        Lead convertedLead = [SELECT ConvertedAccountId, ConvertedContactId FROM Lead WHERE Id = :leads.Id];

        // Assert the lead converted - merged with existing contact if email is the same.
        Assert.areNotEqual(myContacts[0].Id, convertedLead.ConvertedContactId, 'Contact Id should NOT not match');
        Assert.areNotEqual(myContacts[1].Id, convertedLead.ConvertedContactId, 'Contact Id should NOT not match');
        Assert.areNotEqual(myContacts[2].Id, convertedLead.ConvertedContactId, 'Contact Id should NOT not match');
        Assert.areNotEqual(newAcct.Id, convertedLead.ConvertedAccountId, 'Account Id should NOT match');
        Assert.isFalse(updatedLead.IsConverted, 'Lead should not be converted');
    }

    @IsTest
    static void testhandleLeadAutoConvert_update_negative() {
        // Create Account and contact so autoconvert can test against
        //List<Account> newAccts = new List<Account>();
        Account newAcct = new Account(Name = 'CodingBelly Co.');
        insert newAcct;

        List<Contact> myContacts = new List<Contact>();
        myContacts.add(new Contact(LastName = 'Belly', Email = 'test@test.com.invalid', AccountId = newAcct.Id));
        myContacts.add(new Contact(LastName = 'CodingBelly', Email = 'test@test.com.invalid', AccountId = newAcct.Id));
        myContacts.add(new Contact(LastName = 'ApexBelly', Email = '', AccountId = newAcct.Id));
        insert myContacts;
        
        // Create the test leads
        //List<Lead> leadsToConvert = new List<Lead>();
        Lead leads = new Lead(LastName = 'CodeBelly', Company = 'Coding Co.',  Email = 'test@test.com');
        //leadsToConvert.add(leads);
        insert leads;

        Lead updateTheLead = [SELECT Id, Email FROM Lead WHERE Id = :leads.Id];
        updateTheLead.Email = 'test@test.com.invalid';

        // Run the leadAutoConvertHandler
        Test.startTest();
        update updateTheLead;
        Test.stopTest();

        // Return the list of leads processed
        Lead updatedLead = [SELECT Id, IsConverted FROM Lead WHERE Id = :leads.Id];
        Lead convertedLead = [SELECT ConvertedAccountId, ConvertedContactId FROM Lead WHERE Id = :leads.Id];

        // Assert the lead converted - merged with existing contact if email is the same.
        Assert.areNotEqual(myContacts[0].Id, convertedLead.ConvertedContactId, 'Contact Id should NOT not match');
        Assert.areNotEqual(myContacts[1].Id, convertedLead.ConvertedContactId, 'Contact Id should NOT not match');
        Assert.areNotEqual(myContacts[2].Id, convertedLead.ConvertedContactId, 'Contact Id should NOT not match');
        Assert.areNotEqual(newAcct.Id, convertedLead.ConvertedAccountId, 'Account Id should NOT match');
        Assert.isFalse(updatedLead.IsConverted, 'Lead should not be converted');
    }
}   