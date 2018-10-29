using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using Utility;
using WebHome.Helper;
using WebHome.Models.DataEntity;
using WebHome.Models.Locale;

namespace WebHome.Models.ViewModel
{
    public partial class InvoiceViewModelValidator<TEntity>
        where TEntity : class, new()
    {
        public readonly static String[] __InvoiceTypeList = { "01", "02", "03", "04", "05", "06", "07", "08" };
        public static string __DECIMAL_AMOUNT_PATTERN = "^-?\\d{1,12}(.[0-9]{0,4})?$";
        public static string __CELLPHONE_BARCODE = "3J0002";
        public static String __自然人憑證 = "CQ0001";

        protected ModelSource<TEntity> _mgr;
        protected Organization _owner;

        protected InvoiceViewModel _invItem;

        protected InvoiceItem _newItem;
        protected Organization _seller;
        protected InvoiceBuyer _buyer;
        protected InvoiceCarrier _carrier;
        protected InvoiceDonation _donation;
        protected IEnumerable<InvoiceProductItem> _productItems;
      

        public InvoiceViewModelValidator(ModelSource<TEntity> mgr, Organization owner)
        {
            _mgr = mgr;
            _owner = owner;
        }

        public InvoiceItem InvoiceItem
        {
            get
            {
                return _newItem;
            }
        }


        public virtual InvoiceException Validate(InvoiceViewModel dataItem)
        {
            _invItem = dataItem;

            InvoiceException ex;

            _seller = null;
            _newItem = null;

            if ((ex = checkBusiness()) != null)
            {
                return ex;
            }

            if ((ex = checkAmount()) != null)
            {
                return ex;
            }


            if ((ex = checkMandatoryFields()) != null)
            {
                return ex;
            }

            if(!String.IsNullOrEmpty(_invItem.CarrierType) && (ex = checkPublicCarrier()) != null)
            {
                return ex;
            }

            if ((ex = checkInvoiceProductItems()) != null)
            {
                return ex;
            }

            if ((ex = checkInvoice()) != null)
            {
                return ex;
            }


            return null;
        }


        protected virtual InvoiceException checkInvoice()
        {
            _invItem.NPOBAN = _invItem.NPOBAN.GetEfficientString();
            if (_invItem.NPOBAN != null)
            {
                _donation = new InvoiceDonation
                {
                    AgencyCode = _invItem.NPOBAN
                };
            }

            _newItem = new InvoiceItem
            {
                Document = new Document
                {
                    DocDate = DateTime.Now,
                    DocType = (int)Naming.DocumentTypeDefinition.E_Invoice,
                },
                DonateMark = _donation == null ? "0" : "1",
                InvoiceType = (byte)_invItem.InvoiceType,
                SellerID = _seller.CompanyID,
                CustomsClearanceMark = _invItem.CustomsClearanceMark,
                InvoiceSeller = new InvoiceSeller
                {
                    Name = _seller.CompanyName,
                    ReceiptNo = _seller.ReceiptNo,
                    Address = _seller.Addr,
                    ContactName = _seller.ContactName,
                    //CustomerID = String.IsNullOrEmpty(_invItem.GoogleId) ? "" : _invItem.GoogleId,
                    CustomerName = _seller.CompanyName,
                    EMail = _seller.ContactEmail,
                    Fax = _seller.Fax,
                    Phone = _seller.Phone,
                    PersonInCharge = _seller.UndertakerName,
                    SellerID = _seller.CompanyID,
                },
                InvoiceBuyer = _buyer,
                RandomNo = _invItem.RandomNo,
                InvoiceAmountType = new InvoiceAmountType
                {
                    DiscountAmount = _invItem.DiscountAmount,
                    SalesAmount = _invItem.SalesAmount,
                    TaxAmount = _invItem.TaxAmount,
                    TaxRate = _invItem.TaxRate,
                    TaxType = (byte)_invItem.TaxType,
                    TotalAmount = _invItem.PayoffAmount,
                    TotalAmountInChinese = Utility.ValueValidity.MoneyShow(_invItem.PayoffAmount),
                },
                InvoiceCarrier = _carrier,
                InvoiceDonation = _donation,
                PrintMark = _carrier == null ? "Y" : "N",
            };

            _newItem.InvoiceDetails.AddRange(_productItems.Select(p => new InvoiceDetails
            {
                InvoiceProduct = p.InvoiceProduct,
            }));

            if(_newItem.InvoiceBuyer.ReceiptNo!= "0000000000")
            {
                _newItem.PrintMark = "Y";
            }
            else if (_newItem.InvoiceDonation != null || _newItem.InvoiceCarrier != null)
            {
                _newItem.PrintMark = "N";
            }

            try
            {
                using (TrackNoManager trackNoMgr = new TrackNoManager(_mgr, _seller.CompanyID))
                {
                    if (!trackNoMgr.ApplyInvoiceDate(_invItem.InvoiceDate.Value) || !trackNoMgr.CheckInvoiceNo(_newItem))
                    {
                        return new InvoiceException(String.Format("未設定發票字軌或發票號碼已用完，發票開立人統編：{0}", _seller.ReceiptNo));
                    }
                    else
                    {
                        _newItem.InvoiceDate = _invItem.InvoiceDate;
                    }
                }
            }
            catch (Exception ex)
            {
                return new InvoiceException(null, ex);
            }

            return null;
        }

        protected virtual InvoiceException checkBusiness()
        {
            _seller = _mgr.GetTable<Organization>().Where(o => o.CompanyID == _invItem.SellerID).FirstOrDefault();
            if (_seller == null)
            {
                _seller = _mgr.GetTable<Organization>().Where(o => o.ReceiptNo == _invItem.SellerReceiptNo).FirstOrDefault();
            }
            if (_seller == null)
            {
                return new InvoiceException(String.Format("營業人資料錯誤，統一編號:{0}", _invItem.SellerReceiptNo));
            }

            if (String.IsNullOrEmpty(_invItem.BuyerReceiptNo))
            {
                _invItem.BuyerReceiptNo = "0000000000";
            }
            else if (_invItem.BuyerReceiptNo != "0000000000")
            {
                if (!Regex.IsMatch(_invItem.BuyerReceiptNo, "^[0-9]{8}$"))
                {
                    return new InvoiceException(String.Format("公司統一編號錯誤:{0}", _invItem.BuyerReceiptNo)) { RequestName = "BuyerReceiptNo" };
                }
                else if (!_invItem.BuyerReceiptNo.CheckRegno())
                {
                    return new InvoiceException(String.Format("公司統一編號錯誤:{0}", _invItem.BuyerReceiptNo)) { RequestName = "BuyerReceiptNo" };
                }
            }

            if (String.IsNullOrEmpty(_invItem.RandomNo))
            {
                _invItem.RandomNo = String.Format("{0:ffff}", DateTime.Now); //ValueValidity.GenerateRandomCode(4)
            }
            else if (!Regex.IsMatch(_invItem.RandomNo, "^[0-9]{4}$"))
            {
                return new InvoiceException(String.Format("交易隨機碼應由4位數值構成，上傳資料：{0}", _invItem.RandomNo));
            }

            return checkBusinessDetails();
        }

        protected bool checkPublicCarrierId(String carrierId)
        {
            return carrierId != null && carrierId.Length == 8 && carrierId.StartsWith("/");
        }

        protected virtual InvoiceException checkPublicCarrier()
        {

            if (_invItem.CarrierType == __CELLPHONE_BARCODE)
            {
                if (checkPublicCarrierId(_invItem.CarrierId1))
                {
                    _carrier = new InvoiceCarrier
                        {
                            CarrierType = _invItem.CarrierType,
                            CarrierNo = _invItem.CarrierId1,
                            CarrierNo2 = _invItem.CarrierId1
                        };

                    return null;
                }
                else if (checkPublicCarrierId(_invItem.CarrierId2))
                {
                    _carrier = new InvoiceCarrier
                        {
                            CarrierType = _invItem.CarrierType,
                            CarrierNo = _invItem.CarrierId2,
                            CarrierNo2 = _invItem.CarrierId2
                        };

                    return null;
                }
            }
            else if (_invItem.CarrierType == __自然人憑證)
            {
                if (_invItem.CarrierId1 != null && Regex.IsMatch(_invItem.CarrierId1, "^[A-Z]{2}[0-9]{14}$"))
                {
                    _carrier = new InvoiceCarrier
                    {
                        CarrierType = _invItem.CarrierType,
                        CarrierNo = _invItem.CarrierId1,
                        CarrierNo2 = _invItem.CarrierId1
                    };

                    return null;
                }
                else if (_invItem.CarrierId2 != null && Regex.IsMatch(_invItem.CarrierId2, "^[A-Z]{2}[0-9]{14}$"))
                {
                    _carrier = new InvoiceCarrier
                    {
                        CarrierType = _invItem.CarrierType,
                        CarrierNo = _invItem.CarrierId2,
                        CarrierNo2 = _invItem.CarrierId2
                    };

                    return null;
                }
            }

            return new InvoiceException(String.Format("載具類別為非共通性載具，傳送資料：{0}", _invItem.CarrierType));
        }

        protected virtual InvoiceException checkBusinessDetails()
        {
            _buyer = new InvoiceBuyer
            {
                Name = ((int)4).CreateRandomStringCode(),
                ReceiptNo = String.IsNullOrEmpty(_invItem.BuyerReceiptNo) ? "0000000000" : _invItem.BuyerReceiptNo,
                CustomerID = _invItem.CustomerID,
                CustomerName = _invItem.BuyerName,
                ContactName = _invItem.BuyerName,
                Phone = _invItem.Phone,
                Address = _invItem.Address,
                EMail = _invItem.EMail
            };

            return null;
        }



        protected virtual InvoiceException checkAmount()
        {
            //應稅銷售額
            if (!_invItem.SalesAmount.HasValue || _invItem.SalesAmount < 0 || decimal.Floor(_invItem.SalesAmount.Value) != _invItem.SalesAmount.Value)
            {
                return new InvoiceException(String.Format("應稅銷售額合計(新台幣)不可為負數且為整數，上傳資料：{0}", _invItem.SalesAmount)) { RequestName = "PayoffAmount" };
            }


            if (!_invItem.TaxAmount.HasValue || _invItem.TaxAmount < 0 || decimal.Floor(_invItem.TaxAmount.Value) != _invItem.TaxAmount.Value)
            {
                return new InvoiceException(String.Format("營業稅額不可為負數且為整數，上傳資料：{0}", _invItem.TaxAmount)) { RequestName = "PayoffAmount" };
            }

            if (!_invItem.PayoffAmount.HasValue || _invItem.PayoffAmount < 0 || decimal.Floor(_invItem.PayoffAmount.Value) != _invItem.PayoffAmount.Value)
            {
                return new InvoiceException(String.Format("總金額不可為負數且為整數，上傳資料：{0}", _invItem.PayoffAmount)) { RequestName = "PayoffAmount" };
            }

            //課稅別
            if (!Enum.IsDefined(typeof(Naming.TaxTypeDefinition), (int)_invItem.TaxType))
            {
                return new InvoiceException(String.Format("課稅別格式錯誤，上傳資料：{0}", _invItem.TaxType));
            }

            if (_invItem.TaxRate < 0m)
            {
                return new InvoiceException(String.Format("稅率格式錯誤，上傳資料：{0}", _invItem.TaxRate));
            }

            if (_invItem.TaxType == Naming.TaxTypeDefinition.零稅率)
            {
                if (String.IsNullOrEmpty(_invItem.CustomsClearanceMark))
                {
                    return new InvoiceException(String.Format("若為零稅率發票，通關方式註記(CustomsClearanceMark)為必填欄位，上傳資料：{0}", _invItem.CustomsClearanceMark));
                }
                else if (_invItem.CustomsClearanceMark != "1" && _invItem.CustomsClearanceMark != "2")
                {
                    return new InvoiceException(String.Format("通關方式註記格式錯誤，限填非經海關出口：\"1\";或經海關出口：\"2\"，上傳資料：{0}", _invItem.CustomsClearanceMark));
                }
            }
            else if (!String.IsNullOrEmpty(_invItem.CustomsClearanceMark))
            {
                if (_invItem.CustomsClearanceMark != "1" && _invItem.CustomsClearanceMark != "2")
                {
                    return new InvoiceException(String.Format("通關方式註記格式錯誤，限填非經海關出口：\"1\";或經海關出口：\"2\"，上傳資料：{0}", _invItem.CustomsClearanceMark));
                }
            }

            return null;
        }


        protected virtual InvoiceException checkInvoiceProductItems()
        {
            if (_invItem.Brief == null || _invItem.Brief.Length == 0)
            {
                return new InvoiceException("無發票品項明細") { RequestName = "ProductID" };
            }

            short seqNo = 0;
            _productItems = _invItem.Brief.Select(i => new InvoiceProductItem
            {
                InvoiceProduct = new InvoiceProduct { Brief = i },
                CostAmount = _invItem.CostAmount[seqNo],
                ItemNo = _invItem.ItemNo[seqNo],
                Piece = _invItem.Piece[seqNo],
                UnitCost = _invItem.UnitCost[seqNo],
                Remark = _invItem.ItemRemark[seqNo],
                TaxType = (byte)_invItem.TaxType,
                No = (seqNo++)
            }).ToList();


            foreach (var product in _productItems)
            {
                if (String.IsNullOrEmpty(product.InvoiceProduct.Brief) || product.InvoiceProduct.Brief.Length > 256)
                {
                    return new InvoiceException(String.Format("品項名稱不可空白長度不得大於256，傳送資料：{0}", product.InvoiceProduct.Brief));
                }


                if (!String.IsNullOrEmpty(product.PieceUnit) && product.PieceUnit.Length > 6)
                {
                    return new InvoiceException(String.Format("單位格式錯誤，傳送資料：{0}", product.PieceUnit));
                }


                if (!Regex.IsMatch(product.UnitCost.ToString(), __DECIMAL_AMOUNT_PATTERN))
                {
                    return new InvoiceException(String.Format("單價資料格式錯誤，傳送資料：{0}", product.UnitCost));
                }

                if (!Regex.IsMatch(product.CostAmount.ToString(), __DECIMAL_AMOUNT_PATTERN))
                {
                    return new InvoiceException(String.Format("金額格式錯誤，傳送資料：{0}", product.CostAmount));
                }

            }
            return null;
        }

        protected virtual InvoiceException checkMandatoryFields()
        {

            if (_invItem.DonateMark != "0" && _invItem.DonateMark != "1")
            {
                return new InvoiceException(String.Format("捐贈註記錯誤，上傳資料：{0}", _invItem.DonateMark));
            }

            //if(!__InvoiceTypeList.Contains(String.Format("{0:00}",_invItem.InvoiceType)))
            //{
            //    return new Exception(String.Format("發票類別格式錯誤，請依發票種類填寫相應代號\"01\"-\"06\"，上傳資料：{0}", _invItem.InvoiceType));
            //}

            return null;
        }

        protected virtual Exception checkCarrierDataIsComplete()
        {

            if (String.IsNullOrEmpty(_invItem.CarrierType))
            {
                return new InvoiceException("上傳載具資料不完全，請檢查；1.載具類別、2.顯碼或隱瑪至少填一。");
            }
            else
            {
                if (_invItem.CarrierType.Length > 6 || (_invItem.CarrierId1 != null && _invItem.CarrierId1.Length > 64) || (_invItem.CarrierId2 != null && _invItem.CarrierId2.Length > 64))
                    return new InvoiceException(String.Format("載具類別或顯碼ID、隱碼ID的長度超出限制；載具類別：6碼、顯碼及隱碼ID：64。上傳資料→載具類別 {0}、顯碼ID {1}、隱碼ID {2}。", _invItem.CarrierType, _invItem.CarrierId1, _invItem.CarrierId2));

                _carrier = new InvoiceCarrier
                {
                    CarrierType = _invItem.CarrierType
                };

                if (!String.IsNullOrEmpty(_invItem.CarrierId1))
                {
                    if (_invItem.CarrierId1.Length > 64)
                        return new InvoiceException(String.Format("載具類別或顯碼ID、隱碼ID的長度超出限制；載具類別：6碼、顯碼及隱碼ID：64。上傳資料→載具類別 {0}、顯碼ID {1}、隱碼ID {2}。", _invItem.CarrierType, _invItem.CarrierId1, _invItem.CarrierId2));

                    _carrier.CarrierNo = _invItem.CarrierId1;
                }

                if (!String.IsNullOrEmpty(_invItem.CarrierId2))
                {
                    if (_invItem.CarrierId2.Length > 64)
                        return new InvoiceException(String.Format("載具類別或顯碼ID、隱碼ID的長度超出限制；載具類別：6碼、顯碼及隱碼ID：64。上傳資料→載具類別 {0}、顯碼ID {1}、隱碼ID {2}。", _invItem.CarrierType, _invItem.CarrierId1, _invItem.CarrierId2));

                    _carrier.CarrierNo2 = _invItem.CarrierId2;
                }

                if (_carrier.CarrierNo == null)
                {
                    if (_carrier.CarrierNo2 == null)
                    {
                        return new InvoiceException("上傳載具資料不完全，請檢查；1.載具類別、2.顯碼或隱瑪至少填一。");
                    }
                    else
                    {
                        _carrier.CarrierNo = _carrier.CarrierNo2;
                    }
                }
                else
                {
                    if (_carrier.CarrierNo2 == null)
                        _carrier.CarrierNo2 = _carrier.CarrierNo;
                }
            }

            return null;
        }

    }

    public class InvoiceException : Exception
    {
        public InvoiceException() : base() { }
        public InvoiceException(string message) : base(message) { }
        public InvoiceException(string message, Exception innerException) : base(message, innerException) { }

        public String RequestName { get; set; }
    }
}
