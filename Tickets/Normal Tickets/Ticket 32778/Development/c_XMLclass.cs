using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Xml.Serialization;

namespace APIsample
{

	[XmlRoot(ElementName = "errorInfo")]
	public class ErrorInfo
	{

		[XmlElement(ElementName = "errorCode")] 				//error code of result
		public string ErrorCode { get; set; }

		[XmlElement(ElementName = "errorMessage")] 				//error message
		public string ErrorMessage { get; set; }

		[XmlElement(ElementName = "errorMessageVerbose")]		//detailzed error message in case critical error
		public string ErrorMessageVerbose { get; set; }

		[XmlElement(ElementName = "elapsedTime")]				//elapsed time for request processing
		public string ElapsedTime { get; set; }

		[XmlElement(ElementName = "startTime")]					//start time for request processing
		public string StartTime { get; set; }

		[XmlElement(ElementName = "endTime")]					//end time for request processing
		public string EndTime { get; set; }

		[XmlElement(ElementName = "ServerName")]				//Server's name for request processing
		public string ServerName { get; set; }

		[XmlElement(ElementName = "Version")]					//actual version of API
		public string Version { get; set; }

		[XmlElement(ElementName = "warnings")]					//List of warning messages
		public object Warnings { get; set; }
	}

	[XmlRoot(ElementName = "rateDetail")]
	public class RateDetail
	{

		[XmlElement(ElementName = "jurisdictionLevel")]			//jurisdiction level
		public string JurisdictionLevel { get; set; }

		[XmlElement(ElementName = "jurisdictionCode")]			//jurisdiction Code (if any)
		public string JurisdictionCode { get; set; }

		[XmlElement(ElementName = "taxRate")]					//tax rate
		public string TaxRate { get; set; }

		[XmlElement(ElementName = "authorityName")]				//authority name whoi managed tax
		public string AuthorityName { get; set; }
	}

	[XmlRoot(ElementName = "rateDetails")]						//tax breakout basic class
	public class RateDetails
	{

		[XmlElement(ElementName = "rateDetail")]				//list of breakout
		public List<RateDetail> RateDetail { get; set; }
	}

	[XmlRoot(ElementName = "rateInfo")]
	public class RateInfo
	{

		[XmlElement(ElementName = "rateDetails")]				//tax breakout basic class
		public RateDetails RateDetails { get; set; }
	}

	[XmlRoot(ElementName = "salesTax")]
	public class SalesTax
	{

		[XmlElement(ElementName = "taxRate")]
		public string TaxRate { get; set; }

		[XmlElement(ElementName = "rateInfo")]
		public RateInfo RateInfo { get; set; }
	}

	[XmlRoot(ElementName = "useTax")]
	public class UseTax
	{

		[XmlElement(ElementName = "taxRate")]
		public string TaxRate { get; set; }

		[XmlElement(ElementName = "rateInfo")]
		public RateInfo RateInfo { get; set; }
	}

	[XmlRoot(ElementName = "noteDetail")]
	public class NoteDetail
	{

		[XmlElement(ElementName = "jurisdiction")]
		public string Jurisdiction { get; set; }

		[XmlElement(ElementName = "category")]
		public string Category { get; set; }

		[XmlElement(ElementName = "note")]
		public string Note { get; set; }
	}

	[XmlRoot(ElementName = "noteDetails")]
	public class NoteDetails
	{

		[XmlElement(ElementName = "noteDetail")]
		public List<NoteDetail> NoteDetail { get; set; }
	}

	[XmlRoot(ElementName = "notes")]
	public class Notes
	{

		[XmlElement(ElementName = "noteDetails")]
		public NoteDetails NoteDetails { get; set; }
	}

	[XmlRoot(ElementName = "address")]
	public class Address
	{

		[XmlElement(ElementName = "addressLine1")]			// street address
		public string AddressLine1 { get; set; }

		[XmlElement(ElementName = "addressLine2")]			// additional street address
		public string AddressLine2 { get; set; }

		[XmlElement(ElementName = "place")]					// city (place)
		public string Place { get; set; }

		[XmlElement(ElementName = "state")]					// state		
		public string State { get; set; }

		[XmlElement(ElementName = "zipCode")]				// zip code
		public string ZipCode { get; set; }

		[XmlElement(ElementName = "county")]				// county
		public string County { get; set; }

		[XmlElement(ElementName = "latitude")]				// latitude
		public string Latitude { get; set; }

		[XmlElement(ElementName = "longitude")]				// longitude
		public string Longitude { get; set; }

		[XmlElement(ElementName = "salesTax")]				// class for sales Tax info
		public SalesTax SalesTax { get; set; }

		[XmlElement(ElementName = "useTax")]				// class for Use Tax info
		public UseTax UseTax { get; set; }

		[XmlElement(ElementName = "notes")]					// class for list of notes
		public Notes Notes { get; set; }
	}

	[XmlRoot(ElementName = "addresses")]					//class for searched addresses
	public class Addresses
	{

		[XmlElement(ElementName = "address")]
		public List<Address> Address { get; set; }
	}

	[XmlRoot(ElementName = "addressInfo")]
	public class AddressInfo
	{

		[XmlElement(ElementName = "addressResolution")]
		public string AddressResolution { get; set; }

		[XmlElement(ElementName = "addresses")]
		public Addresses Addresses { get; set; }
	}

	[XmlRoot(ElementName = "z2tLookup")]
	public class Z2tLookup
	{

		[XmlElement(ElementName = "errorInfo")]
		public ErrorInfo ErrorInfo { get; set; }

		[XmlElement(ElementName = "addressInfo")]
		public AddressInfo AddressInfo { get; set; }
	}
}