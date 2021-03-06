// Возвращает доступные варианты печати документа.
//
// Вовращаемое значение:
//  Струткура, каждая строка которой соответствует одному из вариантов печати
//  
Функция ПолучитьСтруктуруПечатныхФорм() Экспорт
	
	//[РКХ->]
	Если ОбщегоНазначенияПовтИсп.ИдентификаторРабочейКонфигурации() = "PA" Тогда
    	//Возврат Новый Структура("КС3ГРП, КС3, КСЗ_2, Акт","КС3 ГРП","КС-3","КС-3 Англ","Акт");
		Возврат Новый Структура("КС3ГРП, КС3, КСЗ_2","КС3 ГРП","КС-3","КС-3 Англ");    
	Иначе
		Возврат Новый Структура("КС3, КСЗ_2, Акт","КС-3","КС-3 Англ","Акт");	
	КонецЕсли;
	//[<-РКХ]

КонецФункции // ПолучитьСтруктуруПечатныхФорм()

// Процедура осуществляет печать документа. Можно направить печать на 
// экран или принтер, а также распечатать необходмое количество копий.
//
//  Название макета печати передается в качестве параметра,
// по переданному названию находим имя макета в соответствии.
//
// Параметры:
//  НазваниеМакета - строка, название макета.
//
Процедура Печать(ИмяМакета, КоличествоЭкземпляров = 1, НаПринтер = Ложь, НепосредственнаяПечать = Ложь) Экспорт
	
	Если Реализации.Количество() = 0 Тогда
		#Если Клиент Тогда
		Предупреждение("Для печати формирования печатной формы необходимо указать хотя бы один документ реализации!");
		#КонецЕсли
		Возврат;
	КонецЕсли;
	
	// Получить экземпляр документа на печать
	Если ИмяМакета = "Акт" Тогда
		ТабДокумент = ПечатьАкта();	
	Иначе	
		ТабДокумент = ПечатьКС3(ИмяМакета);	
	КонецЕсли;	
	 #Если Клиент Тогда
	ФормированиеПечатныхФорм.НапечататьДокумент(ТабДокумент, КоличествоЭкземпляров, НаПринтер, РаботаСДиалогами.СформироватьЗаголовокДокумента(ЭтотОбъект), НепосредственнаяПечать);
	#КонецЕСли
	
КонецПроцедуры // Печать

Функция ПечатьАкта()
	
	
	ТабДокумент = Новый ТабличныйДокумент;	
	ТабДокумент.ИмяПараметровПечати = "ПАРАМЕТРЫ_ПЕЧАТИ_АКТПолныхРабот";
	Макет       = ПолучитьМакет("АктПолныхРабот");

	ОбластьМакета = Макет.ПолучитьОбласть("Основная");
	
	ОбластьМакета.Параметры.Дата =  Формат(Дата,"ДФ=dd.MM.yyyy");
	ОбластьМакета.Параметры.Договор = ДоговорКонтрагента.Наименование;
	ОбластьМакета.Параметры.Контрагент = Контрагент.НаименованиеПолное;
	ОбластьМакета.Параметры.Организация = "Филиал Шлюмберже Лоджелко Инк.";
	ОбластьМакета.Параметры.Скважина = Скважина;
	ОбластьМакета.Параметры.Месторождение = Месторождение;
	
	ИтогоСумма=0;
	ИтогоНДС=0;
	
	Для каждого СтрокаРеализация из Реализации Цикл
		для каждого СтрокаТаб из СтрокаРеализация.Документ.Товары Цикл
			ИтогоНДС = ИтогоНДС+ СтрокаТаб.СуммаНДС;
		КонецЦикла;

    	Для каждого СтрокаТаб из СтрокаРеализация.Документ.Услуги Цикл
			
			ИтогоНДС = ИтогоНДС+ СтрокаТаб.СуммаНДС;
		КонецЦикла;
		ИтогоСумма = ИтогоСумма+ СтрокаРеализация.Документ.СуммаДокумента;

	КонецЦикла;

	
	ОбластьМакета.Параметры.Стоимость = ИтогоСумма;
	ОбластьМакета.Параметры.Валюта = ДоговорКонтрагента.ВалютаВзаиморасчетов.НаименованиеПолное;
	ОбластьМакета.Параметры.НДС = ИтогоНДС;
	
    ОбластьМакета.Параметры.ДолжностьЗаказчик = ПринялДолжность;
	ОбластьМакета.Параметры.ФИОЗаказчик = ПринялФИО;
	ОбластьМакета.Параметры.ДолжностьПодрядчик = "Руководитель проекта";
	ОбластьМакета.Параметры.ФИОПодрядчик = Реализации[0].Документ.Руководитель;
    ТабДокумент.Вывести(ОбластьМакета);

	Возврат ТабДокумент;

	
КонецФункции	
Функция ПечатьКС3(ИмяМакета) 
	 #Если клиент Тогда
	ТабДокумент = Новый ТабличныйДокумент;	
	ТабДокумент.ИмяПараметровПечати = "ПАРАМЕТРЫ_ПЕЧАТИ_РеализацияТоваровУслуг_КС3";
	
	Если ИмяМакета = "КС3" Тогда
		Макет       = ПолучитьМакет("КС_3_2");
	//[РКХ->]
	ИначеЕсли ОбщегоНазначенияПовтИсп.ИдентификаторРабочейКонфигурации() = "PA" И ИмяМакета = "КС3ГРП" Тогда	
		ТабДокумент = ПечатьКС3ГРП(ИмяМакета);
	//[<-РКХ]
	Иначе
		Макет       = ПолучитьМакет("КС_3");
	КонецЕсли;

	ОбластьМакета = Макет.ПолучитьОбласть("ШапкаСправки");
	ОбластьМакета.Параметры.ОКПОЗаказчик = Контрагент.КодПоОКПО;
	ОбластьМакета.Параметры.ОКПОПодрядчик = Реализации[0].Документ.ПодразделениеОрганизации.КодПоОКПО;
	ОбластьМакета.Параметры.Договор = "" + ДоговорКонтрагента;
  	Подрядчик= ФормированиеПечатныхФорм.ОписаниеОрганизации(КонтактнаяИнформация.СведенияОЮрФизЛице(Реализации[0].Документ.ПодразделениеОрганизации, Дата), "ПолноеНаименование,ЮридическийАдрес,Телефоны,");
	Если ИмяМакета = "КС3" Тогда
		ОбластьМакета.Параметры.Подрядчик = Подрядчик;
	Иначе	
		ОбластьМакета.Параметры.Подрядчик = Подрядчик+
  		"/ Schlumberger Logelco Inc., No 8 Aquilino de la Guardia Panama 1 Republic of Panama, tel.(+507)2056000 Fax. (507)249 4891 ( via Schlumberger Logelco Inc. division at " + СтрЗаменить(ФормированиеПечатныхФорм.ОписаниеОрганизации(КонтактнаяИнформация.СведенияОЮрФизЛице(Реализации[0].Документ.ПодразделениеОрганизации,Дата), "АнглийскийАдрес, Телефоны, "),"тел","tel");
	КонецЕсли;
	
	Заказчик="" + ФормированиеПечатныхФорм.ОписаниеОрганизации(КонтактнаяИнформация.СведенияОЮрФизЛице(Контрагент, Дата), "ПолноеНаименование,ЮридическийАдрес,Телефоны,"); 
	Если ИмяМакета = "КС3" Тогда
		ОбластьМакета.Параметры.Заказчик = Заказчик;
	Иначе	
		ОбластьМакета.Параметры.Заказчик = Заказчик +
  	  	" / " + Контрагент.DescriptionFull + ", " + СтрЗаменить(ФормированиеПечатныхФорм.ОписаниеОрганизации(КонтактнаяИнформация.СведенияОЮрФизЛице(Контрагент, Дата), "АнглийскийАдрес, Телефоны, "),"тел","tel");
	КонецЕсли;  
	  
	Если ОбщегоНазначения.ЗначениеНеЗаполнено(Месторождение) Тогда
		Месторожд = "";
	Иначе
		Месторожд = ?(ТипЗнч(Месторождение) = Тип("Строка"),Месторождение ,Месторождение.Наименование);
	КонецЕсли;
	
	Если ОбщегоНазначения.ЗначениеНеЗаполнено(Скважина) Тогда
		Скваж = "";
	Иначе
		Скваж = ?(ТипЗнч(Скважина) = Тип("Строка"),Скважина ,Скважина.Наименование);
	КонецЕсли;
	
	ОбластьМакета.Параметры.Месторождение = Месторожд + " местрождение";
	ОбластьМакета.Параметры.Скважина ="Скважина "+ Скваж;
	
	ОбластьМакета.Параметры.День = День(Дата);
	ОбластьМакета.Параметры.Месяц = Месяц(Дата);
	ОбластьМакета.Параметры.Год = Год(Дата);
	ТабДокумент.Вывести(ОбластьМакета);
	
	ОбластьМакета = Макет.ПолучитьОбласть("ШапкаТаблицы");
 	ОбластьМакета.Параметры.ОтчетныйПериодНачало = Формат(НачПериода,"ДФ=dd.MM.yyyy");
	ОбластьМакета.Параметры.ОтчетныйПериодКонец = Формат(КонПериода,"ДФ=dd.MM.yyyy");
	ОбластьМакета.Параметры.НомерДокумента = Номер;
  	ОбластьМакета.Параметры.ДатаДокумента = Формат(Дата,"ДФ=dd.MM.yyyy");
	ТабДокумент.Вывести(ОбластьМакета);
	
	
	ОбластьМакета = Макет.ПолучитьОбласть("СтрокаВсего");
	ТабДокумент.Вывести(ОбластьМакета);

	
	НомерСтроки =0;
	ИтогоСумма=0;
	ИтогоНДС=0;
	
	Для каждого СтрокаРеализация из Реализации Цикл
	Для каждого СтрокаТаб из СтрокаРеализация.Документ.Товары Цикл
		ОбластьМакета = Макет.ПолучитьОбласть("СтрокаТаблицы");
		НомерСтроки=НомерСтроки+1;
		ОбластьМакета.Параметры.НомерСтроки = НомерСтроки; 
		ОбластьМакета.Параметры.НаименованиеРабот = СтрокаТаб.Номенклатура.НаименованиеПолное;
		ОбластьМакета.Параметры.СуммаНачалоРабот = СтрокаТаб.Сумма;
		ОбластьМакета.Параметры.СуммаНачалоГода = СтрокаТаб.Сумма;
        ОбластьМакета.Параметры.СуммаЗаОтчетныйПериод = СтрокаТаб.Сумма;
		ТабДокумент.Вывести(ОбластьМакета);
		ИтогоСумма = ИтогоСумма+ СтрокаТаб.Сумма;
		ИтогоНДС = ИтогоНДС+ СтрокаТаб.СуммаНДС;
	КонецЦикла;

    Для каждого СтрокаТаб из СтрокаРеализация.Документ.Услуги Цикл
		ОбластьМакета = Макет.ПолучитьОбласть("СтрокаТаблицы");
		НомерСтроки = НомерСтроки+1;
		ОбластьМакета.Параметры.НомерСтроки = НомерСтроки;
		ОбластьМакета.Параметры.НаименованиеРабот = СтрокаТаб.Содержание;
		ОбластьМакета.Параметры.СуммаНачалоРабот = СтрокаТаб.Сумма;
		ОбластьМакета.Параметры.СуммаНачалоГода = СтрокаТаб.Сумма;
        ОбластьМакета.Параметры.СуммаЗаОтчетныйПериод = СтрокаТаб.Сумма;
		ТабДокумент.Вывести(ОбластьМакета);
		ИтогоСумма = ИтогоСумма+ СтрокаТаб.Сумма;
		ИтогоНДС = ИтогоНДС+ СтрокаТаб.СуммаНДС;
	КонецЦикла;
	КонецЦикла;
	
	ОбластьМакета = Макет.ПолучитьОбласть("ПодвалТаблицы");
			
	ОбластьМакета.Параметры.Итого = ИтогоСумма;
	ОбластьМакета.Параметры.СуммаНДС = ИтогоНДС;
	ОбластьМакета.Параметры.ВсегоСНДС = ИтогоСумма+ИтогоНДС;
			
	ТабДокумент.Вывести(ОбластьМакета);
	

	Если ИмяМакета = "КС3" Тогда
		ОбластьМакета = Макет.ПолучитьОбласть("Подвал");
		ОбластьМакета.Параметры.ДолжностьЗаказчик = СдалДолжность;
		ОбластьМакета.Параметры.ФИОЗаказчик = СдалФИО;
		ОбластьМакета.Параметры.ДолжностьПодрядчик = ПринялДолжность;
		ОбластьМакета.Параметры.ФИОПодрядчик = ПринялФИО;
		ТабДокумент.Вывести(ОбластьМакета);
	Иначе
		ОбластьМакета = Макет.ПолучитьОбласть("Сдал");
		ОбластьМакета.Параметры.Должность = СдалДолжность + " / " + СдалДолжностьEng;
		ОбластьМакета.Параметры.ФИО = СдалФИО + " / " + СдалФИОEng;
		ТабДокумент.Вывести(ОбластьМакета);
		ОбластьМакета = Макет.ПолучитьОбласть("Принял");
		ОбластьМакета.Параметры.Должность = ПринялДолжность + " / " + ПринялДолжностьEng;
		ОбластьМакета.Параметры.ФИО = ПринялФИО + " / " + ПринялФИОEng;
		ТабДокумент.Вывести(ОбластьМакета);
		Если не ОбщегоНазначения.ЗначениеНеЗаполнено(СогласованоФИО) Тогда
			ОбластьМакета = Макет.ПолучитьОбласть("Согласовано");
			ОбластьМакета.Параметры.Должность = СогласованоДолжность + " / " + СогласованоДолжностьEng;
			ОбластьМакета.Параметры.ФИО = СогласованоФИО + " / " + СогласованоФИОEng;  
			ТабДокумент.Вывести(ОбластьМакета);
		КонецЕсли;
		Если не ОбщегоНазначения.ЗначениеНеЗаполнено(СогласованоФИО1) Тогда
			ОбластьМакета = Макет.ПолучитьОбласть("Согласовано");
			ОбластьМакета.Параметры.Должность = СогласованоДолжность1 + " / " + СогласованоДолжностьEng1;
			ОбластьМакета.Параметры.ФИО = СогласованоФИО1 + " / " + СогласованоФИОEng1;
			ТабДокумент.Вывести(ОбластьМакета);
		КонецЕсли; 		
	КонецЕсли;
	Возврат ТабДокумент;
	 #КонецЕсли
	КонецФункции



Процедура ОбработкаЗаполнения(Основание)
	//{{__КОНСТРУКТОР_ВВОД_НА_ОСНОВАНИИ
	// Данный фрагмент построен конструктором.
	// При повторном использовании конструктора, внесенные вручную изменения будут утеряны!!!
	
	//[РКХ->]
	Если ОбщегоНазначенияПовтИсп.ИдентификаторРабочейКонфигурации() <> "PA" Тогда
    	ДокументОснование = Основание.ССылка;
	КонецЕсли;
	//[<-РКХ]           	
	
	Если ТипЗнч(Основание) = Тип("ДокументСсылка.РеализацияТоваровУслуг") Тогда
		//[РКХ->]
		Если ОбщегоНазначенияПовтИсп.ИдентификаторРабочейКонфигурации() = "PA" Тогда
			ДокументОснование = Основание.ССылка;
		КонецЕсли;
		//[<-РКХ]   
		// Заполнение шапки
		Попытка
			Месторождение = Основание.Услуги[0].Oilfield;
			Скважина = Основание.Услуги[0].Well;
		Исключение
		КонецПопытки;
	
		ДоговорКонтрагента = Основание.ДоговорКонтрагента;
		Контрагент = Основание.Контрагент;
		Организация = Основание.Организация;
		Ответственный = Основание.Ответственный;
		
		СтрокаДок = Реализации.Добавить();
		СтрокаДок.Документ = Основание.Ссылка;
		СтрокаДок.СуммаДокумента = Основание.СуммаДокумента;
		
		ЭтотОбъект.Записать();
	КонецЕсли;
	

	//}}__КОНСТРУКТОР_ВВОД_НА_ОСНОВАНИИ
КонецПроцедуры

//RG-Soft 17.09.13
//
Функция ПечатьКС3ГРП(ИмяМакета) 
#Если клиент Тогда
	ТабДокумент = Новый ТабличныйДокумент;	
	ТабДокумент.ИмяПараметровПечати = "ПАРАМЕТРЫ_ПЕЧАТИ_РеализацияТоваровУслуг_КС3ГРП";
	
	Макет       = ПолучитьМакет("КС3ГРП");

	ОбластьМакета = Макет.ПолучитьОбласть("ШапкаСправки");
	ОбластьМакета.Параметры.ОКПОЗаказчик = Контрагент.КодПоОКПО;
	ОбластьМакета.Параметры.ОКПОПодрядчик = Реализации[0].Документ.Организация.КодПоОКПО;
	ОбластьМакета.Параметры.НомерДоговора = ДоговорКонтрагента.SiebelID;
	
  	Подрядчик= ФормированиеПечатныхФорм.ОписаниеОрганизации(КонтактнаяИнформация.СведенияОЮрФизЛице(Реализации[0].Документ.Организация, Дата), "ПолноеНаименование,ЮридическийАдрес,Телефоны,");
	ОбластьМакета.Параметры.Подрядчик = Подрядчик;
	Заказчик=ФормированиеПечатныхФорм.ОписаниеОрганизации(КонтактнаяИнформация.СведенияОЮрФизЛице(Контрагент, Дата), "ПолноеНаименование,ЮридическийАдрес,Телефоны,"); 
	ОбластьМакета.Параметры.Заказчик = Заказчик;
		
	ТипСтроительства = "";
	ОбластьМакета.Параметры.Объект = "Интенсификация притока нефти методом ГРП. " + ТипСтроительства;
	ОбластьМакета.Параметры.ДатаДоговора = Формат(ДоговорКонтрагента.ДатаНачала,"ДФ=dd.MM.yyyy");
	ОбластьМакета.Параметры.ОтчетныйПериодНачало = Формат(НачПериода,"ДФ=dd.MM.yyyy");
	ОбластьМакета.Параметры.ОтчетныйПериодКонец = Формат(КонПериода,"ДФ=dd.MM.yyyy");
	ОбластьМакета.Параметры.НомерДокумента = Номер;
  	ОбластьМакета.Параметры.ДатаДокумента = Формат(Дата,"ДФ=dd.MM.yyyy");
	ОбластьМакета.Параметры.ВидДеятельности = Реализации[0].Документ.Организация.КодОКВЭД;
	Для каждого Стр Из Реализации[0].Документ.Товары Цикл
		Если НЕ Стр.Ticket.Agreement.Пустая() Тогда
			ДопСогл = "/" + Строка(Стр.Ticket.Agreement.Код);
			ДатаДопС = Формат(Стр.Ticket.Agreement.ДатаНачала,"ДФ=dd.MM.yyyy");
			ДатаДопСогл = "/" + Строка(ДатаДопС);
			Инвест = Стр.Ticket.Agreement.ИнвестПроект;
		КонецЕсли;	
	КонецЦикла;
	Для каждого Стр Из Реализации[0].Документ.Услуги Цикл
		Если НЕ Стр.Ticket.Agreement.Пустая() Тогда
			ДопСогл = "/" + Строка(Стр.Ticket.Agreement.Код);
			ДатаДопС = Формат(Стр.Ticket.Agreement.ДатаНачала,"ДФ=dd.MM.yyyy");
			ДатаДопСогл = "/" + Строка(ДатаДопС);
			Инвест = Стр.Ticket.Agreement.ИнвестПроект
		КонецЕсли;	
	КонецЦикла;
	ОбластьМакета.Параметры.НомерДоСогл = ДопСогл;
	ОбластьМакета.Параметры.ДатаДопСогл = ДатаДопСогл;
	ОбластьМакета.Параметры.ИнвестПроект = Инвест;
	ТабДокумент.Вывести(ОбластьМакета);
	
	ОбластьМакета = Макет.ПолучитьОбласть("ШапкаТаблицы");
	ОбластьМакета.Параметры.Валюта = Реализации[0].Документ.ВалютаДокумента;	
	ТабДокумент.Вывести(ОбластьМакета);	
	
	ОбластьМакета = Макет.ПолучитьОбласть("СтрокаВсего");
	ОбластьМакета.Параметры.СуммаНачалоРабот = Реализации.Итог("СуммаДокумента");
	ОбластьМакета.Параметры.СуммаНачалоГода = Реализации.Итог("СуммаДокумента");
	СуммаЗаОтчетныйПериод = 0;
	Для каждого Стр Из Реализации Цикл
		Если Стр.Документ.Дата>НачПериода И Стр.Документ.Дата<КонПериода Тогда
	    	СуммаЗаОтчетныйПериод = СуммаЗаОтчетныйПериод + Стр.СуммаДокумента;
		КонецЕсли;
	КонецЦикла;
	ОбластьМакета.Параметры.СуммаЗаОтчетныйПериод = СуммаЗаОтчетныйПериод;
	ТабДокумент.Вывести(ОбластьМакета);

	
	НомерСтроки =0;
	ИтогоСумма=0;
	ИтогоНДС=0;
	ИтогоСНДС = 0;
	СуммаВПериоде = 0;
	СуммаНДСВПериоде = 0;
	СуммаСНДСВПериоде = 0;
	Для каждого СтрокаРеализация из Реализации Цикл
		ОбластьМакета = Макет.ПолучитьОбласть("СтрокаТаблицы");
		НомерСтроки=НомерСтроки+1;
		ОбластьМакета.Параметры.НомерСтроки = НомерСтроки; 
		ОбластьМакета.Параметры.СуммаНачалоРабот = СтрокаРеализация.СуммаДокумента;
		ОбластьМакета.Параметры.СуммаНачалоГода = СтрокаРеализация.СуммаДокумента;
		ВПериоде = Ложь;
		Если СтрокаРеализация.Документ.Дата>НачПериода И СтрокаРеализация.Документ.Дата<КонПериода Тогда
			ОбластьМакета.Параметры.СуммаЗаОтчетныйПериод = СтрокаРеализация.СуммаДокумента;
			ВПериоде = Истина;		
		КонецЕсли; 
		Для каждого СтрокаТаб из СтрокаРеализация.Документ.Товары Цикл
			Если СтрокаТаб.Well <> Справочники.Wells.ПустаяСсылка() И СтрокаТаб.Oilfield <> Справочники.Oilfields.ПустаяСсылка() Тогда
				НаименованиеРабот = Строка(СтрокаТаб.Well) + " " + Строка(СтрокаТаб.Oilfield);				 
			КонецЕсли; 
			ИтогоСумма = ИтогоСумма+ СтрокаТаб.Сумма;
			//ИтогоНДС = ИтогоНДС+ СтрокаТаб.СуммаНДС;
			//ИтогоСНДС = ?(СтрокаРеализация.Документ.СуммаВключаетНДС,ИтогоСНДС=ИтогоСНДС+СтрокаТаб.Сумма,ИтогоСНДС=ИтогоСНДС+СтрокаТаб.Сумма+СтрокаТаб.СуммаНДС);
			Если ВПериоде Тогда
				СуммаВПериоде = СуммаВПериоде + СтрокаТаб.Сумма;
				СуммаНДСВПериоде = СуммаНДСВПериоде + СтрокаТаб.СуммаНДС;
				Если СтрокаРеализация.Документ.СуммаВключаетНДС Тогда
					СуммаСНДСВПериоде=СтрокаТаб.Сумма + СуммаСНДСВПериоде;
				Иначе
					СуммаСНДСВПериоде=СтрокаТаб.Сумма+СтрокаТаб.СуммаНДС+СуммаСНДСВПериоде;				
				КонецЕсли;
			КонецЕсли;
		КонецЦикла;
		
		Для каждого СтрокаТаб из СтрокаРеализация.Документ.Услуги Цикл
			Если СтрокаТаб.Well <> Справочники.Wells.ПустаяСсылка() И СтрокаТаб.Oilfield <> Справочники.Oilfields.ПустаяСсылка() Тогда
				НаименованиеРабот = Строка(СтрокаТаб.Well) + " " + Строка(СтрокаТаб.Oilfield);
				ИтогоСумма = ИтогоСумма+ СтрокаТаб.Сумма;				
			КонецЕсли; 		
			//ИтогоНДС = ИтогоНДС+ СтрокаТаб.СуммаНДС;
			//ИтогоСНДС = ?(СтрокаРеализация.Документ.СуммаВключаетНДС,ИтогоСНДС=ИтогоСНДС+СтрокаТаб.Сумма,ИтогоСНДС=ИтогоСНДС+СтрокаТаб.Сумма+СтрокаТаб.СуммаНДС);
			Если ВПериоде Тогда
				СуммаВПериоде = СуммаВПериоде + СтрокаТаб.Сумма;
				СуммаНДСВПериоде = СуммаНДСВПериоде + СтрокаТаб.СуммаНДС;
				Если СтрокаРеализация.Документ.СуммаВключаетНДС Тогда
					СуммаСНДСВПериоде=СтрокаТаб.Сумма + СуммаСНДСВПериоде;
				Иначе
					СуммаСНДСВПериоде=СтрокаТаб.Сумма+СтрокаТаб.СуммаНДС+СуммаСНДСВПериоде;				
				КонецЕсли;
			КонецЕсли;
		КонецЦикла;
		ОбластьМакета.Параметры.НаименованиеРабот = НаименованиеРабот;
		ТабДокумент.Вывести(ОбластьМакета);
	КонецЦикла;
	
	ОбластьМакета = Макет.ПолучитьОбласть("ПодвалТаблицы");			
	ОбластьМакета.Параметры.Итого = ИтогоСумма;
	ОбластьМакета.Параметры.ИтогоВПериоде = СуммаВПериоде;
	ОбластьМакета.Параметры.СуммаНДС = СуммаНДСВПериоде;
	ОбластьМакета.Параметры.ВсегоСНДС = СуммаСНДСВПериоде;
	
	ТабДокумент.Вывести(ОбластьМакета);
	
	
	ОбластьМакета = Макет.ПолучитьОбласть("Подвал");
	ОбластьМакета.Параметры.ДолжностьКонтрагент = СдалДолжность;
	ОбластьМакета.Параметры.ФИОКонтрагент = СдалФИО;
	ОбластьМакета.Параметры.ДолжностьОрганизация = ПринялДолжность;
	ОбластьМакета.Параметры.ФИООрганизация = ПринялФИО;
	ТабДокумент.Вывести(ОбластьМакета);			
	Возврат ТабДокумент;
#КонецЕсли
КонецФункции
