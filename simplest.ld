ENTRY(_start)

SECTIONS {
	.text.boot 0x8000 : {
		*(.text.boot)
	}

	/*
	 * Next we put the rest of the code.
	 */
	.text : {
		*(.text)
	}

	/*
	 * Next we put the data.
	 */
	.data : {
		*(.data)
	}
}
