using Uno; 
using Uno.UX;

namespace Fuse
{
	public partial class Node
	{
        int _lineNumber;
        string _fileName;

        [UXLineNumber]
		public int LineNumber
		{
			get { return _lineNumber; }
			set { _lineNumber = value; }
		}

		[UXSourceFileName]
		public string FileName
		{
			get { return _fileName; }
			set { _fileName = value; }
		}
    }
}