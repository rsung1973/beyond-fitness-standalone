﻿//------------------------------------------------------------------------------
// <auto-generated>
//     這段程式碼是由工具產生的。
//     執行階段版本:4.0.30319.42000
//
//     對這個檔案所做的變更可能會造成錯誤的行為，而且如果重新產生程式碼，
//     變更將會遺失。
// </auto-generated>
//------------------------------------------------------------------------------

// 
// 此原始程式碼由 xsd 版本=4.6.1055.0 自動產生。
// 
namespace WebHome.Models.MIG3_1.C0701 {
    using System.Xml.Serialization;
    
    
    /// <remarks/>
    [System.CodeDom.Compiler.GeneratedCodeAttribute("xsd", "4.6.1055.0")]
    [System.SerializableAttribute()]
    [System.Diagnostics.DebuggerStepThroughAttribute()]
    [System.ComponentModel.DesignerCategoryAttribute("code")]
    [System.Xml.Serialization.XmlTypeAttribute(AnonymousType=true, Namespace="urn:GEINV:eInvoiceMessage:C0701:3.1")]
    [System.Xml.Serialization.XmlRootAttribute(Namespace="urn:GEINV:eInvoiceMessage:C0701:3.1", IsNullable=false)]
    public partial class VoidInvoice {
        
        /// <remarks/>
        public string VoidInvoiceNumber;
        
        /// <remarks/>
        public string InvoiceDate;
        
        /// <remarks/>
        public string BuyerId;
        
        /// <remarks/>
        public string SellerId;
        
        /// <remarks/>
        public string VoidDate;
        
        /// <remarks/>
        [System.Xml.Serialization.XmlElementAttribute(DataType="time")]
        public System.DateTime VoidTime;
        
        /// <remarks/>
        public string VoidReason;
        
        /// <remarks/>
        public string Remark;
    }
}