
// В этом модуле дублируются функции из других модулей, чтобы обеспечить повторное использование возвращаемых значений 

// ДОДЕЛАТЬ. ПЕРЕНЕСТИ ВЫЗЫВАЕМУЮ ФУНКЦИЮ В МОДУЛЬ МЕНЕДЖЕРА
Функция ПолучитьLegalEntityOfCountry(Country) Экспорт
	
	Возврат ImportExportСервер.ПолучитьLegalEntityOfCountry(Country);
	
КонецФункции

Функция ПолучитьLegalEntityПоРеквизитамTMS(CompanyCode, CountryCode, ERPID, FinanceLocCode, FinanceProcess) Экспорт
	
	Возврат Справочники.LegalEntities.ПолучитьПоРеквизитамTMS(CompanyCode, CountryCode, ERPID, FinanceLocCode, FinanceProcess);
	
КонецФункции

Функция ПолучитьRCACountryПоTMSID(TMSID) Экспорт
	
	Возврат Справочники.CountriesOfProcessLevels.ПолучитьПоTMSID(TMSID);
	
КонецФункции

Функция ПолучитьProcessLevelПоCountryCodeИTMSID(CountryCode, TMSID) Экспорт
	
	Возврат Справочники.ProcessLevels.ПолучитьПоCountryCodeИTMSID(CountryCode, TMSID);
	
КонецФункции

Функция ПолучитьProcessLevelПоRCACountry(RCACountry) Экспорт
	
	Возврат Справочники.ProcessLevels.ПолучитьПоRCACountry(RCACountry);
	
КонецФункции

Функция ПолучитьMOTПоTMSID(TMSID) Экспорт
	
	Возврат Справочники.MOTs.ПолучитьПоTMSID(TMSID);
	
КонецФункции

Функция ПолучитьCountryHUBПоTMSID(TMSID) Экспорт
	
	Возврат Справочники.CountriesHUBs.ПолучитьПоTMSID(TMSID);
	
КонецФункции

Функция ПолучитьPortПоTMSID(TMSID) Экспорт
	
	Возврат Справочники.SeaAndAirPorts.ПолучитьПоTMSID(TMSID);
	
КонецФункции

Функция ПолучитьAUПоКоду(Код) Экспорт
	
	Возврат Справочники.КостЦентры.ПолучитьПоКоду(Код);
	
КонецФункции

Функция ПолучитьIncotermsПоКоду(Код) Экспорт
	
	Возврат Справочники.Incoterms.ПолучитьПоКоду(Код);
	
КонецФункции

Функция ПолучитьConsignToПоTMSID(TMSID) Экспорт
	
	Возврат Справочники.ConsignTo.ПолучитьПоTMSID(TMSID);
	
КонецФункции

Функция ПолучитьCurrencyПоНаименованиюEng(НаименованиеEng) Экспорт
	
	Возврат Справочники.Валюты.ПолучитьПоНаименованиюEng(НаименованиеEng);
	
КонецФункции

Функция ПолучитьUOMПоTMSID(TMSID) Экспорт
	
	Возврат Справочники.UOMs.ПолучитьПоTMSID(TMSID);
	
КонецФункции

Функция ПолучитьUOMПоTMSIDForItemUOM(TMSID) Экспорт
	
	Возврат Справочники.UOMs.ПолучитьПоTMSIDForItemUOM(TMSID);
	
КонецФункции

Функция ПолучитьРеквизитыTMSContact(ContactGid) Экспорт
	
	Возврат Обработки.PullMasterDataFromTMS.ПолучитьРеквизитыContact(ContactGid);
	
КонецФункции

// { RGS VChaplygin 28.03.2016 23:38:15 - Добавим отправку от системной учетной записи
//Функция ПолучитьИнтернетПочтовыйПрофиль() Экспорт
Функция ПолучитьИнтернетПочтовыйПрофиль(ИспользоватьСистемнуюУчетнуюЗапись = Ложь) Экспорт
	
	// { RGS VChaplygin 28.03.2016 23:38:15 - Добавим отправку от системной учетной записи
	//Возврат ImportExportСервер.ПолучитьИнтернетПочтовыйПрофиль();
	Возврат ImportExportСервер.ПолучитьИнтернетПочтовыйПрофиль(ИспользоватьСистемнуюУчетнуюЗапись);
	// } RGS VChaplygin 28.03.2016 23:38:15 - Добавим отправку от системной учетной записи
	
КонецФункции

Функция ПолучитьИнтернетПочтовыйПрофильRCATLM() Экспорт
	
	Возврат ImportExportСервер.ПолучитьИнтернетПочтовыйПрофильRCATLM();
	
КонецФункции

Функция ПолучитьPackingTypeПоКоду(Код) Экспорт
	
	Возврат Справочники.PackingTypes.ПолучитьПоКоду(Код);
	
КонецФункции

Функция ПолучитьPackingTypeПоTMSID(TMSID) Экспорт
	
	Возврат Справочники.PackingTypes.ПолучитьПоTMSID(TMSID);
	
КонецФункции

Функция ПолучитьLocationQualifierПоКоду(Код) Экспорт
	
	Возврат Справочники.LocationQualifiers.ПолучитьПоКоду(Код);
	
КонецФункции

Функция ПолучитьContactQualifierПоDomainAndQualifier(DomainAndQualifier) Экспорт
	
	Возврат Справочники.ContactQualifiers.ПолучитьПоDomainAndQualifier(DomainAndQualifier);
	
КонецФункции

Функция ПолучитьSLSRCAПоКоду(Код) Экспорт
	
	Возврат Справочники.SLSRCA.ПолучитьПоКоду(Код);
	
КонецФункции

Функция ПолучитьParentCompanyПоКоду(Код) Экспорт
	
	Возврат Справочники.SoldTo.НайтиПоКоду(Код);
	
КонецФункции

Функция ПолучитьИсключаемыеИзЗатратERPTreatments() Экспорт
	
	МассивERPTreatments = Новый Массив;
	
	МассивERPTreatments.Добавить(Перечисления.ТипыЗаказа.A);
	МассивERPTreatments.Добавить(Перечисления.ТипыЗаказа.I);
			
	Возврат МассивERPTreatments;
	
КонецФункции

Функция ПолучитьERPTreatmentsДляКоторыхОбязателенСерийныйНомер() Экспорт
	
	МассивERPTreatments = Новый Массив;
	
	МассивERPTreatments.Добавить(Перечисления.ТипыЗаказа.A);
	МассивERPTreatments.Добавить(Перечисления.ТипыЗаказа.U);
	МассивERPTreatments.Добавить(Перечисления.ТипыЗаказа.V);
	МассивERPTreatments.Добавить(Перечисления.ТипыЗаказа.LOAN);
	МассивERPTreatments.Добавить(Перечисления.ТипыЗаказа.FAT);
			
	Возврат МассивERPTreatments;
	
КонецФункции
