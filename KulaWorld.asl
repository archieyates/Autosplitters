// Author: Reicha7 (www.archieyates.co.uk)

// ePSXe version 2.0
state("ePSXe", "SLUS-00724")
{
	// End level screen bit set
	int end : "ePSXe.exe", 0x8BECBC;
}

split
{
	// Will probably add some settings to allow filtering based on IL or on worlds
	if(current.end == 1 && old.end == 0)
	{
		return true;
	}
}