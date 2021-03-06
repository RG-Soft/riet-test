Процедура ВыполнитьДвижениеПоРегиструПроводкиDSSОбщие(ДанныеДляПроводки) Экспорт
	
	ДвиженияОбщие = РегистрыНакопления.ПроводкиDSSОбщие.СоздатьНаборЗаписей();
	ДвиженияОбщие.Отбор.Регистратор.Установить(ДанныеДляПроводки.Регистратор);
	ДвиженияОбщие.Записывать = Истина;
	
	Строка = ДвиженияОбщие.Добавить();
	
	Строка.Период = ДанныеДляПроводки.Период;	
	Строка.AccountLawson = ДанныеДляПроводки.AccountLawson ;
	Строка.FiscalType = ДанныеДляПроводки.FiscalType;
	Строка.AU = ДанныеДляПроводки.AU; 
	Строка.LegalEntity = ДанныеДляПроводки.LegalEntity;      
	Строка.BaseAmount = ДанныеДляПроводки.BaseAmount;
	Строка.System = ДанныеДляПроводки.System;
	Строка.GltObjId = ДанныеДляПроводки.GltObjId; 
	Строка.DateLawson = ДанныеДляПроводки.DateLawson; 
	Строка.Reference = ДанныеДляПроводки.Reference;
	Строка.Description = ДанныеДляПроводки.Description;
	Строка.TranAmount = ДанныеДляПроводки.TranAmount; 
	Строка.Currency = ДанныеДляПроводки.Currency;
	Строка.GUID =  ДанныеДляПроводки.GUID;
	Строка.PeriodLawson = ДанныеДляПроводки.PeriodLawson;
	Строка.Company = ДанныеДляПроводки.Company;
	Строка.Модуль = ДанныеДляПроводки.Модуль;  
	Строка.RubAmount = ДанныеДляПроводки.RubAmount;
	Строка.FiscAmount = ДанныеДляПроводки.FiscAmount;
	Строка.TempDiff = ДанныеДляПроводки.TempDiff;
	Строка.PermDiff = ДанныеДляПроводки.PermDiff;
	Строка.ExchDiff = ДанныеДляПроводки.ExchDiff;  
	
	ДвиженияОбщие.Записать();    	
	
КонецПроцедуры

Процедура ВыполнитьДвижениеПоРегиструПроводкиDSSSB(ДанныеДляПроводки,LawsonInvoice) Экспорт  
	
	ДвиженияSB = РегистрыНакопления.ПроводкиDSS_SB.СоздатьНаборЗаписей();
	ДвиженияSB.Отбор.Регистратор.Установить(ДанныеДляПроводки.Регистратор);
	ДвиженияSB.Записывать = Истина;
	
	Строка = ДвиженияSB.Добавить();
	
	Строка.Период = ДанныеДляПроводки.Период;	
	Строка.Type = ДанныеДляПроводки.FiscalType;	
	Строка.ArInvoice = LawsonInvoice;
	Строка.CustomerNumber = ДанныеДляПроводки.КонтрагентLawson;
	Строка.AccountUnit = ДанныеДляПроводки.AU; 
	Строка.Account = ДанныеДляПроводки.AccountLawson; 
	Строка.CurrencyCode = ДанныеДляПроводки.Currency;
	Строка.FiscalYear = НачалоГода(ДанныеДляПроводки.Период); 
	Строка.TranAmount = ДанныеДляПроводки.TranAmount; 
	Строка.BaseAmount = ДанныеДляПроводки.BaseAmount; 
	Строка.Mgmtctry  = ДанныеДляПроводки.GeoMarket.Код;                			
	Строка.Company = ДанныеДляПроводки.Company;
	Строка.Location = ДанныеДляПроводки.AU.ПодразделениеОрганизации; 				
	Строка.MgmtNIS = ДанныеДляПроводки.AccountLawson.Родитель.Родитель.Код; 				
	Строка.SummaryAcct = ДанныеДляПроводки.AccountLawson.Родитель.Код; 
	Строка.SummaryAcctDesc = ДанныеДляПроводки.AccountLawson.Родитель.Наименование;
	//Строка.SubAccount = ; //не заполняем
	Строка.AccountingPeriod = Месяц(ДанныеДляПроводки.Период);
	Строка.Activity = ДанныеДляПроводки.Activity;
	Строка.SourceCode = ДанныеДляПроводки.SourceCode;
	Строка.System = ДанныеДляПроводки.System;
	Строка.Reference = ДанныеДляПроводки.Reference;
	Строка.Description = ДанныеДляПроводки.Description;
	Строка.CustomerName = ДанныеДляПроводки.CustomerName;
	Строка.GltObjId = ДанныеДляПроводки.GltObjId;     
	
	ДвиженияSB.Записать();	
	
КонецПроцедуры

Процедура ВыполнитьДвижениеПоРегиструПроводкиDSSFA(ДанныеДляПроводки) Экспорт
	
	Если НЕ ДанныеДляПроводки.System = "AM" Тогда
		Возврат;	
	КонецЕсли; 
	
	// Справка по условию	
	//"AMDEADJ" //DEPRECIATION ADJUSTMENT (Кт 02)
	//"AMDEDIS" //DEPRECIATION DISPOSAL   (Дт 02)
	//"AMDEPR"  //DEPRECIATION            (Кт 02)
	//"AMDETRF" //DEPRECIATION TRANSFER   (Кт 02)
	//"AMFAADD" //ASSETS ADDITION         (Дт 01)
	//"AMFAADJ" //ASSETS ADJUSTMENT       (Дт 01)
	//"AMFADIS" //ASSETS DISPOSAL         (Кт 01)
	//"AMFATRF" //ASSETS TRANSFER         (Дт 01)   
	Код = СокрЛП(ДанныеДляПроводки.FiscalType.Код);
	Если НЕ (Код = "AMDEADJ" 
		ИЛИ Код = "AMDEDIS" 
		ИЛИ Код = "AMDEPR" 
		ИЛИ Код = "AMDETRF" 
		ИЛИ Код = "AMFAADD" 
		ИЛИ Код = "AMFAADJ" 
		ИЛИ Код = "AMFADIS" 
		ИЛИ Код = "AMFATRF") Тогда  		
		Возврат;		
	КонецЕсли;  		
	
	ДвиженияFA = РегистрыНакопления.ПроводкиDSS_FA.СоздатьНаборЗаписей();
	ДвиженияFA.Отбор.Регистратор.Установить(ДанныеДляПроводки.Регистратор);
	ДвиженияFA.Записывать = Истина;   	
	
	Строка = ДвиженияFA.Добавить();
	Строка.Asset = ДанныеДляПроводки.AssetLawson;
	Строка.AU =  ДанныеДляПроводки.AU;
	Строка.Account = ДанныеДляПроводки.AccountLawson;
	Строка.BaseAmount =  ДанныеДляПроводки.BaseAmount;
	Строка.GltObjId =  ДанныеДляПроводки.GltObjId;
	Строка.Description = ДанныеДляПроводки.Description;
	Строка.Type = ДанныеДляПроводки.FiscalType;	
	Строка.Период = ДанныеДляПроводки.Период;
	
	Если Код = "AMDEADJ"    //DEPRECIATION ADJUSTMENT
		ИЛИ Код = "AMDEPR"  //DEPRECIATION 
		ИЛИ Код = "AMDETRF" //DEPRECIATION TRANSFER  
		ИЛИ Код = "AMFAADD" //ASSETS ADDITION  
		ИЛИ Код = "AMFAADJ" //ASSETS ADJUSTMENT 
		ИЛИ Код = "AMFATRF" //ASSETS TRANSFER 
		Тогда
		Строка.ВидДвижения = ВидДвиженияНакопления.Приход;
	Иначе	
		Строка.ВидДвижения = ВидДвиженияНакопления.Расход;
		Строка.BaseAmount = - Строка.BaseAmount;
	КонецЕсли;     
	
	ДвиженияFA.Записать(); 
	
КонецПроцедуры

Процедура ВыполнитьДвижениеПоРегиструПоРегиструМатериальныеАктивы(ДанныеДляПроводки) Экспорт
	
	Код = СокрЛП(ДанныеДляПроводки.FiscalType.Код);
	Если НЕ (Код = "AP##FAFM" 
		ИЛИ Код = "APD3PFAFM" 
		ИЛИ Код = "APDIRFAFM" 
		ИЛИ Код = "FA cost") Тогда  		
		Возврат;		
	КонецЕсли;  	
	
	Запрос = Новый Запрос;    		
	Запрос.УстановитьПараметр("Ссылка", ДанныеДляПроводки.Регистратор);
	Запрос.УстановитьПараметр("ВалютаРуб", Справочники.Валюты.НайтиПоКоду("643"));
	Запрос.УстановитьПараметр("Валюта", Справочники.Валюты.НайтиПоКоду("840"));
	Запрос.УстановитьПараметр("AccountLawsonRNI", ПланыСчетов.Lawson.НайтиПоКоду("201900"));
	Запрос.УстановитьПараметр("AccountLawsonINR", ПланыСчетов.Lawson.НайтиПоКоду("130508"));
	Запрос.УстановитьПараметр("Период", ДанныеДляПроводки.PeriodLawson); 
	Запрос.Текст = "ВЫБРАТЬ
	               |	ПроводкаDSS.Ссылка КАК ПроводкаДеталейСКП,
	               |	ПроводкаDSS.BaseAmount КАК Сумма,
	               |	ВЫБОР
	               |		КОГДА ПроводкаDSS.Ссылка.Currency = &ВалютаРуб
	               |			ТОГДА ПроводкаDSS.Ссылка.TranAmount
	               |		ИНАЧЕ ПроводкаDSS.Ссылка.BaseAmount * ЕСТЬNULL(КурсыВалют.Курс, 0)
	               |	КОНЕЦ КАК СуммаРуб,
	               |	ПроводкаDSS.Ссылка.Дата КАК Период,
	               |	ВЫБОР
	               |		КОГДА ПроводкаDSS.Ссылка.AccountLawson = &AccountLawsonRNI
	               |			ТОГДА ""RNI""
	               |		ИНАЧЕ ВЫБОР
	               |				КОГДА ПроводкаDSS.Ссылка.AccountLawson = &AccountLawsonINR
	               |					ТОГДА ""INR""
	               |				ИНАЧЕ ВЫРАЗИТЬ("""" КАК СТРОКА(15))
	               |			КОНЕЦ
	               |	КОНЕЦ КАК Тип,
	               |	ПроводкаDSS.PoNumber,
	               |	ПроводкаDSS.POLine.Ссылка КАК POLine,
	               |	ПроводкаDSS.POLine.Количество КАК Количество
	               |ИЗ
	               |	Документ.ПроводкаDSS КАК ПроводкаDSS
	               |		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.КурсыВалют КАК КурсыВалют
	               |		ПО ПроводкаDSS.PeriodLawson = КурсыВалют.Период
	               |ГДЕ
	               |	КурсыВалют.Валюта = &Валюта
	               |	И КурсыВалют.Период = &Период
	               |	И ПроводкаDSS.Ссылка = &Ссылка
	               |;
	               |
	               |////////////////////////////////////////////////////////////////////////////////
	               |ВЫБРАТЬ
	               |	РаспределениеМатериаловИзКнигиПокупокINVENTORY.Ссылка КАК ДокРаспределениеМА,
	               |	ПроводкаDSS.Ссылка КАК ПроводкаСКП
	               |ИЗ
	               |	Документ.ПроводкаDSS КАК ПроводкаDSS
	               |		ЛЕВОЕ СОЕДИНЕНИЕ Документ.РаспределениеМатериаловИзКнигиПокупок.INVENTORY КАК РаспределениеМатериаловИзКнигиПокупокINVENTORY
	               |		ПО ПроводкаDSS.Ссылка = РаспределениеМатериаловИзКнигиПокупокINVENTORY.ПроводкаДеталейСКП
	               |			И ((НЕ РаспределениеМатериаловИзКнигиПокупокINVENTORY.Ссылка.ПометкаУдаления))
	               |ГДЕ
	               |	ПроводкаDSS.Ссылка.Модуль = ЗНАЧЕНИЕ(Перечисление.МодулиРазработки.InventoryCosts)
	               |	И РаспределениеМатериаловИзКнигиПокупокINVENTORY.Ссылка ЕСТЬ NULL 
	               |	И ПроводкаDSS.Ссылка = &Ссылка";

				   
	Результат = Запрос.ВыполнитьПакет();
	РезультатДляМА = Результат[0].Выгрузить();
		
	ДвиженияМА = РегистрыНакопления.МатериальныеАктивы.СоздатьНаборЗаписей();
	ДвиженияМА.Отбор.Регистратор.Установить(ДанныеДляПроводки.Регистратор);
	ДвиженияМА.Записывать = Истина;
	
	Для Каждого СтрокаТЗПроводок Из РезультатДляМА цикл
		Движение = ДвиженияМА.ДобавитьПриход();
		Движение.ПроводкаДеталейСКП = СтрокаТЗПроводок.ПроводкаДеталейСКП;
		Движение.Период = СтрокаТЗПроводок.Период;
		Движение.Сумма = СтрокаТЗПроводок.Сумма;
		Движение.СуммаРуб = СтрокаТЗПроводок.СуммаРуб;
	КонецЦикла;
	ДвиженияМА.Записать();
	//Документ  Распределение МА
	Выборка = Результат[1].Выбрать();
	// проверяем наличие документа для проводки AP, если нет - создаем
	Если Выборка.Следующий() Тогда 
		ДокРаспределениеМА = Документы.РаспределениеМатериаловИзКнигиПокупок.СоздатьДокумент();
		ДокРаспределениеМА.Дата = ДанныеДляПроводки.Период;
		Выборка.Сбросить();
		Пока Выборка.Следующий() цикл 
			ДанныеНовойСтроки = РезультатДляМА.Найти(Выборка.ПроводкаСКП, "ПроводкаДеталейСКП");
			НоваяСтрока = ДокРаспределениеМА.INVENTORY.Добавить();
			ЗаполнитьЗначенияСвойств(НоваяСтрока,ДанныеНовойСтроки);
		КонецЦикла;
		//НачатьТранзакцию(РежимУправленияБлокировкойДанных.Автоматический);
			InventoryСервер.ЗаписатьДокументВВыбранномРежиме(ДокРаспределениеМА, РежимЗаписиДокумента.Проведение);
		//ЗафиксироватьТранзакцию();
	КонецЕсли;
             	
КонецПроцедуры
