public with sharing class AccountController {
    public static final Integer CONTACT_PAGE_SIZE = 2;

    public List<SelectOption> accountOptions {get; set;}
    public Account acc {get; set;}
    public Id selectedId {get; set;}
    public List<Contact> contacts {get; set;}
    public Integer pageNumber {get; set;}
    public Integer totalContacts {get; set;}
    public Boolean isCreateAccount {get; set;}
    public Boolean isCreateContact {get; set;}
    public Account newAcc {get; set;}
    public Contact newContact {get; set;}

    public Boolean hasPreviousPage {
        get {
            return pageNumber > 1;
        }
        set;
    }

    public Boolean hasNextPage {
        get {
            return pageNumber < Math.ceil(totalContacts / CONTACT_PAGE_SIZE);
        }
        set;
    }


    public AccountController() {
        accountOptions = new List<SelectOption>();
        List<Account> accs = [SELECT Name FROM Account ORDER BY Name ASC];

        if(!accs.isEmpty()) {
            selectedId = accs[0].Id;
            fetchAccount(accs[0].Id);

            for(Account a: accs) {
                accountOptions.add(new SelectOption(a.id, a.Name));
            }
        }

        isCreateAccount = false;
        isCreateContact = false;
    }

    public void handleOpenContactForm() {
        isCreateContact= true;
        newContact = new Contact(AccountId=selectedId);
    }

    public void handleCloseContactForm() {
        isCreateContact = false;
        newContact = null;
    }

    public void handleSaveContact() {
        insert newContact;
        fetchAccount(selectedId);

        handleCloseContactForm();
    }

    public void handleOpenAccForm() {
        isCreateAccount = true;
        newAcc = new Account();
    }

    public void handleCloseAccForm() {
        isCreateAccount = false;
        newAcc = null;
    }

    public void handleSaveAccount() {
        insert newAcc;
        accountOptions.add(new SelectOption(newAcc.id, newAcc.Name));
        handleCloseAccForm();
    }

    public void handleAccountChange() {
        fetchAccount(selectedId);
    }

    public void handlePreviousPage() {
        pageNumber--;
        contacts = fetchContacts((pageNumber - 1) * CONTACT_PAGE_SIZE, acc.Id);
    }

    public void handleNextPage() {
        pageNumber++;
        contacts = fetchContacts((pageNumber - 1) * CONTACT_PAGE_SIZE, acc.Id);
    }

    private void fetchAccount(Id accId) {
        acc = [SELECT Name, AccountNumber, 	Type,
            SLAExpirationDate__c, Phone, Industry,
            AnnualRevenue, Rating, Fax, NumberOfEmployees
            FROM Account WHERE Id =: accId LIMIT 1];  

        totalContacts = Database.countQuery(
            'SELECT count() FROM Contact WHERE AccountId = :accId');
        pageNumber = 1;

        contacts = fetchContacts(0, accId);
    }

    private List<Contact> fetchContacts(Integer offset, Id accId) {
        return [SELECT Name, Title, Phone FROM Contact WHERE AccountId =:accId LIMIT :CONTACT_PAGE_SIZE OFFSET :offset];
    }
}
