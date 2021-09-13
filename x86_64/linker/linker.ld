ENTRY( entry_point );
PHYS_BASE = 1M;
REAL_BASE = 0x0002000;

SECTIONS
{
	. = PHYS_BASE;

	.boot :
	{
		KEEP( *( .multiboot_header ) )
	}

	/*__physreal_diff = . - REAL_BASE;
	.text16 REAL_BASE : AT( ADDR( .text16) + __physreal_diff )*/
	.text16 :
	{
		/*__realmode_vma_start = .;
		__realmode_lma_start = LOADADDR(.text16);*/
		*( .text16 )
	}
	. = ALIGN(4);
	/*__realmode_vma_end = .;
	__realmode_secsize   = ((__realmode_vma_end)-(__realmode_vma_start));
	__realmode_secsize_l = __realmode_secsize >> 2;
	__realmode_lma_end   = __realmode_vma_start + __physreal_diff + __realmode_secsize;

	. += __physreal_diff;*/
	.text : AT( ADDR( .text ) )
	{
		*( .text )
	}

	.data :
	{
		*( .data )
	}

	.bss (NOLOAD) :
	{
		. = ALIGN( 8 );
		*( .bss );
	}

}
