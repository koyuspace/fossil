public enum Dragonstone.Ui.Document.TokenType {
	PARAGRAPH,
	TITLE,
	LINK,
	QUOTE,
	SEARCH, //the uri will be a pattern containg a '{search}' wich will be replaced by the actual search
	ERROR, //Gophertype 3
	PARSER_ERROR, //when the parser encounters an error
	DESCRIPTION, //of what comes above
	LIST_ITEM,
	EMPTY_LINE;
	
}
