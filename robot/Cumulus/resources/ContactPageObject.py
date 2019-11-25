from cumulusci.robotframework.pageobjects import ListingPage
from cumulusci.robotframework.pageobjects import DetailPage
from cumulusci.robotframework.pageobjects import pageobject
from NPSP import npsp_lex_locators



@pageobject("Listing", "Contact")
class ContactListingPage(ListingPage):
    object_name = "Contact"

    @property
    def npsp(self):
        return self.builtin.get_library_instance('NPSP')

    @property
    def cumulusci(self):
        return self.builtin.get_library_instance('cumulusci.robotframework.CumulusCI')


    def populate_contact_form(self, **kwargs):
        """"""
        for key, value in kwargs.items():
            if key == "Primary Address Type":
                self.npsp.select_value_from_dropdown(key,value)
                
            elif "Mailing" in key:
                self.npsp.search_field_by_value(key,value)
                
            else:
                locator = npsp_lex_locators["object"]["field"].format(key)
                self.salesforce._populate_field(locator, value)    


@pageobject("Details", "Contact")
class ContactDetailPage(DetailPage):
    object_name = "Contact"

    @property
    def npsp(self):
        return self.builtin.get_library_instance('NPSP')

    @property
    def cumulusci(self):
        return self.builtin.get_library_instance('cumulusci.robotframework.CumulusCI')
