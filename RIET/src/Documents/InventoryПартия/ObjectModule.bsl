
Процедура ПередЗаписью(Отказ, РежимЗаписи, РежимПроведения)
	
	Дельта = Проводки.Итог("FiscalSum");
	
	Responsible = ПараметрыСеанса.ТекущийПользователь;
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("ТабЧасть", Проводки);
	Запрос.Текст = "ВЫБРАТЬ
	               |	InventoryПартияПроводки.ПроводкаДеталейСКП
	               |ПОМЕСТИТЬ ВТТабЧасть
	               |ИЗ
	               |	&ТабЧасть КАК InventoryПартияПроводки
	               |;
	               |
	               |////////////////////////////////////////////////////////////////////////////////
	               |ВЫБРАТЬ Первые 1
	               |	ВТТабЧасть.ПроводкаДеталейСКП.AU КАК AU,
				   |	ВТТабЧасть.ПроводкаДеталейСКП.VendorVname КАК VendorVname,
				   |	ВТТабЧасть.ПроводкаДеталейСКП.POLine.КостЦентр.Segment КАК Segment
	               |ИЗ
	               |	ВТТабЧасть КАК ВТТабЧасть
	               |ГДЕ
	               |	ВТТабЧасть.ПроводкаДеталейСКП.System = ""IC""
	               |;
	               |
	               |////////////////////////////////////////////////////////////////////////////////
	               |ВЫБРАТЬ
				   //Пахоменков Rg-Soft в документе это поле называется по другому	
				   //|    ВТТабЧасть.ПроводкаДеталейСКП.Период КАК ПериодПроводки,   			  
				   |    ВТТабЧасть.ПроводкаДеталейСКП.PeriodLawson КАК ПериодПроводки,
	               |	ВТТабЧасть.ПроводкаДеталейСКП.PoNumber КАК PoNumber,
				   // Пахоменков Rg-Soft в документе это поле называется по другому	
				   //|	ВТТабЧасть.ПроводкаДеталейСКП.Описание КАК ItemCode,
				   |	ВТТабЧасть.ПроводкаДеталейСКП.Description КАК ItemCode,				   									  
	               |	ВТТабЧасть.ПроводкаДеталейСКП.Представление КАК Представление
	               |ИЗ
	               |	ВТТабЧасть КАК ВТТабЧасть";
	
	МассивРезультатов = Запрос.ВыполнитьПакет();
	ВыборкаAU = МассивРезультатов[1].Выбрать();
	
	Если ВыборкаAU.Следующий() Тогда 
		AU = ВыборкаAU.AU;
		VendorVname = ВыборкаAU.VendorVname;
		Segment = ВыборкаAU.Segment;
	КонецЕсли;
	
	Выборка = МассивРезультатов[2].Выбрать();
	
	Пока Выборка.Следующий() цикл 
				
		// проверяем PO number  в проводке и в шапке
		Если Выборка.PoNumber <> PoNumber Тогда
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"""PO number"" в проводке " + Выборка.Представление + " не соответствует ""PO number"" в шапке документа!",,,,
			Отказ);
		КонецЕсли;
			
		// проверяем Item code  в проводке и в шапке
	    Если Выборка.ItemCode <> ItemCode Тогда
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"""Item сode"" в проводке " + Выборка.Представление + " не соответствует ""Item сode"" в шапке документа!",,,,
			Отказ);
		КонецЕсли;
		
		//дата партии не может быть меньше периода проводки
		Если Выборка.ПериодПроводки > Дата Тогда
			Дата = Выборка.ПериодПроводки;
        КонецЕсли;	
	
	КонецЦикла;
	
	ПроверитьЗаполнениеРеквизитов(Отказ);
    			
	ПроверитьНаличиеПроводокВДругихДокументах(Отказ);
		          	
КонецПроцедуры
                 
Процедура ПроверитьЗаполнениеРеквизитов(Отказ)
	
	Если НЕ ЗначениеЗаполнено(Дата) Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
		"Поле ""Date"" не заполнено!",
		ЭтотОбъект, "Дата", , Отказ);
	КонецЕсли;
	
	Если НЕ ЗначениеЗаполнено(PONumber) Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
		"Поле ""PO number"" не заполнено!",
		ЭтотОбъект, "PONumber", , Отказ);
	КонецЕсли;
	
	Если НЕ ЗначениеЗаполнено(ItemCode) Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
		"Поле ""Item code"" не заполнено!",
		ЭтотОбъект, "ItemCode", , Отказ);
	КонецЕсли;
	
	Если НЕ ЗначениеЗаполнено(AU) Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
		"Поле ""AU"" не заполнено!",
		ЭтотОбъект, "AU", , Отказ);
	КонецЕсли;
	    		
КонецПроцедуры

Процедура ПроверитьНаличиеПроводокВДругихДокументах(Отказ)
	
	ПроводкиДеталейСКП = Проводки.ВыгрузитьКолонку("ПроводкаДеталейСКП");
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("Ссылка", Ссылка);
	Запрос.УстановитьПараметр("ПроводкиДеталейСКП", ПроводкиДеталейСКП);
	
	Запрос.Текст = "ВЫБРАТЬ
	               |	InventoryПартияПроводки.ПроводкаДеталейСКП,
	               |	InventoryПартияПроводки.Ссылка.Представление КАК Представление
	               |ИЗ
	               |	Документ.InventoryПартия.Проводки КАК InventoryПартияПроводки
	               |ГДЕ
	               |	(НЕ InventoryПартияПроводки.Ссылка.ПометкаУдаления)
	               |	И InventoryПартияПроводки.ПроводкаДеталейСКП В(&ПроводкиДеталейСКП)
	               |	И Не InventoryПартияПроводки.Ссылка = &Ссылка";
	
	Выборка = Запрос.Выполнить().Выбрать();
	
	// проверяем наличие документа
	Пока Выборка.Следующий() цикл
		
		 ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
		 	"Проводка деталей СКП "+ Выборка.ПроводкаДеталейСКП +" уже добавлена в документ: " + Выборка.Представление + "!");
		 Отказ = Истина;
		
	КонецЦикла; 
	    		
КонецПроцедуры
 
Процедура ОбработкаПроведения(Отказ, РежимПроведения)
	
	Если Проводки.Количество() > 0 Тогда 
		ВыполнитьДвиженияПоРегистрам(Отказ, РежимПроведения);
	Иначе 
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю("В табличной части документа "+ЭтотОбъект+" нет ни одной проводки!");
		Отказ = Истина;
	КонецЕсли;
     		
КонецПроцедуры

Процедура ВыполнитьДвиженияПоРегистрам(Отказ, РежимПроведения)
	
	Движения.InventoryTangibleAssetsCosts.Записывать = Истина;
	МассивПроводок = Новый Массив;

    Для Каждого СтрокаПроводки из Проводки цикл
		
		// InventoryTangibleAssetsCostsОбороты
		Движение = Движения.InventoryTangibleAssetsCosts.ДобавитьРасход();
		Движение.ПроводкаДеталейСКП = СтрокаПроводки.ПроводкаДеталейСКП;
		Движение.Период = Дата;
		Движение.Количество = СтрокаПроводки.Количество;
		Движение.FiscalSum = СтрокаПроводки.FiscalSum;
		Движение.ManagementSum = СтрокаПроводки.ManagementSum;
		
		МассивПроводок.Добавить(СтрокаПроводки.ПроводкаДеталейСКП);
				
	КонецЦикла;
	
	// проверка наличия проводок 
	Движения.InventoryTangibleAssetsCosts.Записать();
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("МассивПроводок", МассивПроводок);
	Запрос.Текст =
	"ВЫБРАТЬ
	|	InventoryTangibleAssetsCostsОстатки.ПроводкаДеталейСКП.Представление КАК ПроводкаПредставление
	|ИЗ
	|	РегистрНакопления.InventoryTangibleAssetsCosts.Остатки(, ПроводкаДеталейСКП В (&МассивПроводок)) КАК InventoryTangibleAssetsCostsОстатки";
	
	Выборка = Запрос.Выполнить().Выбрать();
	
	Пока Выборка.Следующий() Цикл
		
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
		"В регистре Inventory tangible assets costs не закрыта сумма по проводке DSS деталей счетов книги покупок:  
		|"+ Выборка.ПроводкаПредставление + "!");
		Отказ = Истина;
		
	КонецЦикла;
	
	Если Не Отказ и Дельта <> 0 Тогда 
		
		// ПроводкиDSSОбщие
		Движения.ПроводкиDSSОбщие.Записывать = Истина;
		
		Запрос = Новый Запрос;
		Запрос.УстановитьПараметр("Ссылка", Ссылка);
		Запрос.УстановитьПараметр("Дата", Дата);
		Запрос.УстановитьПараметр("Дельта", Дельта);
	    Запрос.УстановитьПараметр("ВалютаSLB", Справочники.Валюты.НайтиПоКоду("999"));
		Запрос.Текст = "ВЫБРАТЬ
		               |	КурсыВалютСрезПоследних.Курс
		               |ПОМЕСТИТЬ КурсSLB
		               |ИЗ
		               |	РегистрСведений.КурсыВалют.СрезПоследних(&Дата, Валюта = &ВалютаSLB) КАК КурсыВалютСрезПоследних
		               |;
		               |
		               |////////////////////////////////////////////////////////////////////////////////
		               |ВЫБРАТЬ ПЕРВЫЕ 1
		               |	InventoryПартияПроводки.ПроводкаДеталейСКП,
		               |	&Дельта / КурсSLB.Курс КАК Дельта,
		               |	InventoryПартияПроводки.ManagementSum,
		               |	InventoryПартияПроводки.ПроводкаДеталейСКП.AU КАК AU,
		               |	InventoryПартияПроводки.ПроводкаДеталейСКП.AU.TaxRegistration КАК LegalEntity,
		               |	InventoryПартияПроводки.ПроводкаДеталейСКП.AccountLawson КАК AccountLawson,
		               |	InventoryПартияПроводки.ПроводкаДеталейСКП.Описание КАК Description
		               |ИЗ
		               |	Документ.InventoryПартия.Проводки КАК InventoryПартияПроводки,
		               |	КурсSLB КАК КурсSLB
		               |ГДЕ
		               |	InventoryПартияПроводки.ПроводкаДеталейСКП.System = ""IC""
		               |	И InventoryПартияПроводки.Ссылка = &Ссылка";
		
		Выборка = Запрос.Выполнить().Выбрать();
		
		Если Выборка.Следующий() Тогда       		
				//201900 или 130508
				Движение = Движения.ПроводкиDSSОбщие.Добавить();
				Движение.Период = Дата;
				Движение.AccountLawson = Выборка.AccountLawson;
				Движение.AU = Выборка.AU;
				Движение.LegalEntity = Выборка.LegalEntity;
				//Движение.FiscalType = ;    		
				Движение.BaseAmount = 0;
				Движение.RubAmount = -Дельта;     //сумма дельты в фискале     
				Движение.FiscAmount = - Выборка.Дельта;   // /курс SLB        
				Движение.PermDiff =  Выборка.Дельта;
				Движение.Currency = Справочники.Валюты.НайтиПоКоду("840");  // USD
				Движение.Description = Выборка.Description;
				Движение.GltObjId = 1000000000;
				Движение.GUID = Новый УникальныйИдентификатор;
				Движение.Модуль = Перечисления.МодулиРазработки.InventoryCosts;
				
				//529703
				Движение = Движения.ПроводкиDSSОбщие.Добавить();
				Движение.Период = Дата;
				Движение.AccountLawson = ПланыСчетов.Lawson.НайтиПоКоду("529703");
				Движение.AU = Выборка.AU;
				Движение.LegalEntity = Выборка.LegalEntity;
				//Движение.FiscalType = ;
				Движение.BaseAmount = 0;
				Движение.RubAmount = Дельта;     //сумма дельты в фискале
				Движение.FiscAmount = Выборка.Дельта;     // /курс SLB
				Движение.PermDiff =  - Выборка.Дельта;
				Движение.Currency = Справочники.Валюты.НайтиПоКоду("840");  // USD
				Движение.Description = Выборка.Description; 	
				Движение.GltObjId = 1000000000;
				Движение.GUID = Новый УникальныйИдентификатор;
				Движение.Модуль = Перечисления.МодулиРазработки.InventoryCosts;
		КонецЕсли;
		
	КонецЕсли;
              	  		
КонецПроцедуры


