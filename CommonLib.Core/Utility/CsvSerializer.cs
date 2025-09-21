//===================================================================================
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
//===================================================================================
// This code is released under the terms of the CPOL license, 
//===================================================================================

using System;
using System.Collections;
using System.Collections.Generic;
using System.ComponentModel;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Text;


namespace Csv.Serialization
{
	/// <summary>
	/// Serialize and Deserialize Lists of any object type to CSV.
	/// </summary>
	public class CsvSerializer<T> where T : class, new()
	{
		#region Fields
		private bool _ignoreEmptyLines = true;

		private bool _ignoreReferenceTypesExceptString = true;

		private string _newlineReplacement = ((char)0x254).ToString();

        private List<PropertyInfo> _properties;
        private List<FieldInfo> _fields;

		private string _replacement = ((char)0x255).ToString();

		private string _rowNumberColumnTitle = "RowNumber";

		private char _separator = ',';

		private bool _useEofLiteral = false;

		private bool _useLineNumbers = true;

		private bool _useTextQualifier = false;

        private Encoding _encodig = Encoding.UTF8;

		#endregion Fields

		#region Properties
		public bool IgnoreEmptyLines
		{
			get { return _ignoreEmptyLines; }
			set { _ignoreEmptyLines = value; }
		}

		public bool IgnoreReferenceTypesExceptString
		{
			get { return _ignoreReferenceTypesExceptString; }
			set { _ignoreReferenceTypesExceptString = value; }
		}

		public string NewlineReplacement
		{
			get { return _newlineReplacement; }
			set { _newlineReplacement = value; }
		}

		public string Replacement
		{
			get { return _replacement; }
			set { _replacement = value; }
		}

		public string RowNumberColumnTitle
		{
			get { return _rowNumberColumnTitle; }
			set { _rowNumberColumnTitle = value; }
		}

		public char Separator
		{
			get { return _separator; }
			set { _separator = value; }
		}

		public bool UseEofLiteral
		{
			get { return _useEofLiteral; }
			set { _useEofLiteral = value; }
		}

		public bool UseLineNumbers
		{
			get { return _useLineNumbers; }
			set { _useLineNumbers = value; }
		}

		public bool UseTextQualifier
		{
			get { return _useTextQualifier; }
			set { _useTextQualifier = value; }
		}

        public Encoding CsvEncodig
        {
            get { return _encodig; }
            set { _encodig = value; }
        }

		#endregion Properties

		/// <summary>
		/// Csv Serializer
		/// Initialize by selected properties from the type to be de/serialized
		/// </summary>
		public CsvSerializer()
		{
			var type = typeof(T);

            initialize(type, true);
            initializeFields(type, true);
        }

        public CsvSerializer(Object prototype,bool orderByName)
        {
            var type = prototype.GetType();
            initialize(type, orderByName);
            initializeFields(type, orderByName);
        }

        private void initializeFields(Type type,bool orderByName)
        {
            var fields = type.GetFields(/*BindingFlags.Public*/);

            var q = fields.AsQueryable();

            if (IgnoreReferenceTypesExceptString)
            {
                q = q.Where(a => a.FieldType.IsValueType || a.FieldType.Name == "String");
            }

            IQueryable<FieldInfo> r;
            if (orderByName)
            {
                r = from a in q
                    where a.GetCustomAttribute<CsvIgnoreAttribute>() == null
                    orderby a.Name
                    select a;
            }
            else
            {
                r = from a in q
                    where a.GetCustomAttribute<CsvIgnoreAttribute>() == null
                    select a;
            }

            _fields = r.ToList();
        }

        private void initialize(Type type, bool orderByName)
        {
            var properties = type.GetProperties(BindingFlags.Public | BindingFlags.Instance
                | BindingFlags.GetProperty | BindingFlags.SetProperty);


            var q = properties.AsQueryable();

            if (IgnoreReferenceTypesExceptString)
            {
                q = q.Where(a => a.PropertyType.IsValueType || a.PropertyType.Name == "String");
            }

            IQueryable<PropertyInfo> r;
            if (orderByName)
            {
                r = from a in q
                    where a.GetCustomAttribute<CsvIgnoreAttribute>() == null
                    orderby a.Name
                    select a;
            }
            else
            {
                r = from a in q
                    where a.GetCustomAttribute<CsvIgnoreAttribute>() == null
                    select a;
            }

            _properties = r.ToList();
        }


		/// <summary>
		/// Deserialize
		/// </summary>
		/// <param name="stream">stream</param>
		/// <returns></returns>
		public IList<T> Deserialize(Stream stream)
		{
			string[] columns;
			string[] rows;

			try
			{
				using (var sr = new StreamReader(stream))
				{
					columns = sr.ReadLine().Split(Separator);
					rows = sr.ReadToEnd().Split(new string[] { Environment.NewLine }, StringSplitOptions.None);
				}

			}
			catch (Exception ex)
			{
				throw new InvalidCsvFormatException("The CSV File is Invalid. See Inner Exception for more inoformation.", ex);
			}

			var data = new List<T>();

			for (int row = 0; row < rows.Length; row++)
			{
				var line = rows[row];

				if (IgnoreEmptyLines && string.IsNullOrWhiteSpace(line))
				{
					continue;
				}
				else if (!IgnoreEmptyLines && string.IsNullOrWhiteSpace(line))
				{
					throw new InvalidCsvFormatException(string.Format(@"Error: Empty line at line number: {0}", row));
				}

				var parts = line.Split(Separator);

				var firstColumnIndex = UseLineNumbers ? 2 : 1;
				if (parts.Length == firstColumnIndex && parts[firstColumnIndex - 1] != null && parts[firstColumnIndex - 1] == "EOF")
				{
					break;
				}

				var datum = new T();

				var start = UseLineNumbers ? 1 : 0;
				for (int i = start; i < parts.Length; i++)
				{
					var value = parts[i];
					var column = columns[i];

					// continue of deviant RowNumber column condition
					// this allows for the deserializer to implicitly ignore the RowNumber column
					if (column.Equals(RowNumberColumnTitle) && !_properties.Any(a => a.Name.Equals(RowNumberColumnTitle)))
					{
						continue;
					}

					value = value
						.Replace(Replacement, Separator.ToString())
						.Replace(NewlineReplacement, Environment.NewLine).Trim();

                    var p = _properties.FirstOrDefault(a => a.Name.Equals(column, StringComparison.InvariantCultureIgnoreCase));
                    var f = _fields.FirstOrDefault(a => a.Name.Equals(column, StringComparison.InvariantCultureIgnoreCase));


                    /// ignore property csv column, Property not found on targing type
                    if (p == null && f == null)
                    {
                        continue;
                    }

					if (UseTextQualifier)
					{
						if (value.IndexOf("\"") == 0)
							value = value.Substring(1);

						if (value[value.Length - 1].ToString() == "\"")
							value = value.Substring(0, value.Length - 1);
					}

					var converter = TypeDescriptor.GetConverter(p.PropertyType);
					var convertedvalue = converter.ConvertFrom(value);

                    if (p != null)
                        p.SetValue(datum, convertedvalue);
                    if (f != null)
                        f.SetValue(datum, convertedvalue);
				}

				data.Add(datum);
			}

			return data;
		}

		/// <summary>
		/// Serialize
		/// </summary>
		/// <param name="stream">stream</param>
		/// <param name="data">data</param>
		public void Serialize(Stream stream, IEnumerable<T> data)
		{
			using (var sw = new StreamWriter(stream,_encodig))
			{
                Serialize(sw, data);
			}
		}

        private bool headerWritten = false;
        public void Serialize(TextWriter writer, IEnumerable<T> data)
        {
            var sb = new StringBuilder();
            var values = new List<string>();

            if (headerWritten)
            {
                writer.WriteLine();
            }
            else
            {
                sb.AppendLine(GetHeader());
                headerWritten = true;
            }

            var row = 1;
            foreach (var item in data)
            {
                values.Clear();

                if (UseLineNumbers)
                {
                    values.Add(row++.ToString());
                }

                foreach (var p in _properties)
                {
                    var raw = p.GetValue(item);
                    var value = raw == null ? "" :
                        raw.ToString()
                        .Replace(Separator.ToString(), Replacement)
                        .Replace(Environment.NewLine, NewlineReplacement);

                    if (UseTextQualifier || value.IndexOf(Separator) >= 0)
                    {
                        value = "\"" + value.Replace("\"", "\"\"") + "\"";
                    }

                    values.Add(value);
                }

                foreach (var p in _fields)
                {
                    var raw = p.GetValue(item);
                    var value = raw == null ? "" :
                        raw.ToString()
                        .Replace(Separator.ToString(), Replacement)
                        .Replace(Environment.NewLine, NewlineReplacement);

                    if (UseTextQualifier || value.IndexOf(Separator) >= 0)
                    {
                        value = "\"" + value.Replace("\"", "\"\"") + "\"";
                    }

                    values.Add(value);
                }
                sb.AppendLine(string.Join(Separator.ToString(), values.ToArray()));
            }

            if (UseEofLiteral)
            {
                values.Clear();

                if (UseLineNumbers)
                {
                    values.Add(row++.ToString());
                }

                values.Add("EOF");

                sb.AppendLine(string.Join(Separator.ToString(), values.ToArray()));
            }

            writer.Write(sb.ToString().Trim());
            
        }

		/// <summary>
		/// Get Header
		/// </summary>
		/// <returns></returns>
		private string GetHeader()
		{
            var header = _properties.Select(a => a.Name).Union(_fields.Select(a => a.Name));

			if (UseLineNumbers)
			{
				header = new string[] { RowNumberColumnTitle }.Union(header);
			}

			return string.Join(Separator.ToString(), header.ToArray());
		}
	}

	public class CsvIgnoreAttribute : Attribute { }

	public class InvalidCsvFormatException : Exception
	{
		/// <summary>
		/// Invalid Csv Format Exception
		/// </summary>
		/// <param name="message">message</param>
		public InvalidCsvFormatException(string message)
			: base(message)
		{
		}

		public InvalidCsvFormatException(string message, Exception ex)
			: base(message, ex)
		{
		}
	}
}
