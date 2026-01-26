# %%
import pandas as pd
from idscrub import IDScrub

# %%
scrub = IDScrub(
    [
        "Our names are Hamish McDonald, L. Salah, and Elena Suárez.",
        "My number is +441111111111 and I work at the Department for Business and Trade, 15 Elf Road, AA11 1AA, Lapland",
    ]
)

scrubbed_texts = scrub.scrub(
    scrub_methods=[
        "spacy_entities",
        "presidio_entities",
        "uk_phone_numbers",
        "uk_addresses",
        "uk_postcodes",
        "email_addresses",
        "ip_addresses",
        "google_phone_numbers",
    ]
)

print(scrubbed_texts)

# %%
scrub = IDScrub(
    [
        "Our names are Hamish McDonald, L. Salah, and Elena Suárez.",
        "My number is +441111111111 and I work at Department for Business and Trade, 15 Elf Road, AA11 1AA, Lapland",
        "My number is +18028681981 and I work at Innovations for Poverty Action, 2801 E Columbia St, Seattle, WA 98122, USA",
        "My IBAN code is GB91BKEN10000041610008",
    ]
)

# scrubbed_texts = scrub.spacy_entities(model_name="en_core_web_trf", entities=["PERSON"])
scrub.uk_addresses()
scrubbed_texts = scrub.presidio_entities(
    entities=["PERSON", "PHONE_NUMBER", "EMAIL_ADDRESS", "LOCATION", "IBAN_CODE"]
)

print(scrubbed_texts)

# %%
scrub = IDScrub(
    [
        "Our names are Hamish McDonald, L. Salah, and Elena Suárez.",
    ]
)
scrubbed_texts = scrub.spacy_entities(model_name="en_core_web_trf", entities=["PERSON"])

print(scrubbed_texts)

# %%
data = {
    "ID": ["A", "B", "C", "D", "E"],
    "Pride and Prejudice": [
        "Mr. Darcy walked off; and Elizabeth remained with no very cordial feelings toward him.",
        "Mr. Bennet was so odd a mixture of quick parts, sarcastic humour, reserve, and caprice.",
        "Elizabeth's spirits were so high that they could not be damped for long.",
        "The business of her life was to get her daughters married.",
        "She is tolerable; but not handsome enough to tempt me.",
    ],
    "The Adventures of Sherlock Holmes": [
        "To Sherlock Holmes she is always the woman.",
        "You see, but you do not observe.",
        "The world is full of obvious things which nobody by any chance ever observes.",
        "I am a brain, Watson. The rest of me is a mere appendix.",
        "When you have eliminated the impossible, whatever remains, however improbable, must be the truth.",
    ],
    "Frankenstein": [
        "My dear Victor, do not waste your time upon this; it is sad trash.",
        "Learn from me, if not by my precepts, at least by my example.",
        "I had worked hard for nearly two years, for the sole purpose of infusing life into an inanimate body.",
        "Nothing is more painful to the human mind than a great and sudden change.",
        "Beware; for I am fearless, and therefore powerful.",
    ],
    "Fake book": [
        "The letter to freddie.mercury@queen.com was stamped with SW1A 2AA. His IBAN was GB91BKEN10000041610008.",
        "She forwarded the memo from Mick Jagger and David Bowie to her chief of staff, noting the postcode SW1A 2WH.",
        "The dossier marked confidential came from serena.williams@tennis.com, with SW19 5AE etched in bold across the envelope.",
        "A message arrived just as the Downing Street clock struck midnight.",
        "They did not expected a reply from otis.redding@dockofthebay.org, especially one routed through EH8 8DX.",
    ],
}

df = pd.DataFrame(data)
df

# %%
scrubbed_df, scrubbed_data = IDScrub.dataframe(
    df=df, id_col="ID", exclude_cols=["Frankenstein"], scrub_methods=["all"]
)

# %%
scrubbed_df

# %%
scrubbed_data

# %%
