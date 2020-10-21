public with sharing class AccountController {
public static final Integer CONTACT_PAGE_SIZE = 10;

    public List<SelectOption> accountOptions {get; set;}
    public Account acc {get; set;}
    public Id selectedId {get; set;}
    public List<Contact> contacts {get; set;}
    public Integer pageNumber {get; set;}
    public Integer totalContacts {get; set;}

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
            'SELECT count() FROM Contact WHERE Id = :accId');
        pageNumber = 1;

        contacts = fetchContacts(0, accId);
    }

    private List<Contact> fetchContacts(Integer offset, Id accId) {
        return [SELECT Name, Title, Phone FROM Contact WHERE AccountId =:accId LIMIT :CONTACT_PAGE_SIZE OFFSET :offset];
    }
}
