public class Fossil.Ui.Document.Token : Object {
	
	public string text = "";
	public string? uri = null;
	public bool preformatted = false;
	public bool inlined = false; //don't start a new paragraph if possible
	public Fossil.Ui.Document.TokenType token_type;
	public uint level = 0;
	
	
	public Token(Fossil.Ui.Document.TokenType token_type, uint level, string text, string? uri = null, bool preformatted = false, bool inlined = false){
		this.token_type = token_type;
		this.level = level;
		this.text = text;
		this.uri = uri;
		this.preformatted = preformatted;
		this.inlined;
	}
	
	public Token.parser_error(uint level, string text){
		this.token_type = Fossil.Ui.Document.TokenType.PARSER_ERROR;
		this.level = level;
		this.text = text;
	}
}

/*
Example: The following geminitext will be pared into

-------------------------------------------------
v
# Some Example
A paragraph below the first headline
## A second Headline
```With a preformatted block
With    a
  preformatted
 block
```
=> gemini://example.org and a link

# List

* one item
* two items
* 11 items

The above is a list example,
below is a quote

> Someone once said something
- By someone else

-------------------------------------------------

type level uri preformatted inlined
text

PARAGRAPH 0
A paragraph above the first headline
TITLE 0
Some Example
PARAGRAPH 0
A paragraph below the first headline
TITLE 1
A second Headline
PARAGRAPH 1 null true
With    a
  preformatted
 block
DESCRIPTION 1
With a preformatted block
LINK 1 gemini://example.org
and a link
EMPTY_LINE 1
HEADLINE 0
List
EMPTY_LINE 0
LIST_ITEM 0
one item
LIST_ITEM 0
two items
LIST_ITEM 0
11 items
EMPTY_LINE 0
PARAGRAPH 0
The above is a list example,
below is a quote
EMPTY_LINE 0
QUOTE 0
Someone once said something
PARAGRAPH 0
- By someone else

*/
