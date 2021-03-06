
&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	// { RGS VShamin 04.05.2016 12:52:32 - 
	//Параметры.Свойство("Код", Код);
	//Параметры.Свойство("Дата", Дата);
	//Параметры.Свойство("ВидОперации", ВидОперации);
	//Параметры.Свойство("СостояниеЗаявки", СостояниеЗаявки);
	//Параметры.Свойство("ИзменяемыйКлиент", ИзменяемыйКлиент);
	//Параметры.Свойство("Инициатор", Инициатор);
	//Параметры.Свойство("Комментарий", Комментарий);
	//Параметры.Свойство("Ссылка", Ссылка);
	Если НЕ Параметры.НоваяЗаявка Тогда
		Параметры.Свойство("Наименование", Наименование);
		Параметры.Свойство("Код", Код);
		Параметры.Свойство("Дата", Дата);
		Параметры.Свойство("ВидОперации", ВидОперации);
		Параметры.Свойство("СостояниеЗаявки", СостояниеЗаявки);
		Параметры.Свойство("ИзменяемыйКлиент", ИзменяемыйКлиент);
		Параметры.Свойство("Инициатор", Инициатор);
		Параметры.Свойство("Комментарий", Комментарий);
		Параметры.Свойство("Ссылка", Ссылка);
	Иначе
		Элементы.Наименование.ТолькоПросмотр = Ложь;
		Элементы.Дата.ТолькоПросмотр = Ложь;
		Элементы.ВидОперации.ТолькоПросмотр = Ложь;
		СостояниеЗаявки = "Новая";
		ВидОперации = "РегистрацияНовогоОбъекта";
		Элементы.ИзменяемыйКлиент.ТолькоПросмотр = Ложь;
		Элементы.Комментарий.ТолькоПросмотр = Ложь;
		Элементы.ФормаЗаписать.Доступность = Истина;
		Инициатор = глЗначениеПеременной("глТекущийПользователь");
		Дата = ТекущаяДата();
	КонецЕсли;
	
	УзелОбмена = ПланыОбмена.rgsОбменКлиентамиЧерезУниверсальныйФормат.ПолучитьУзелОбменаСERM();
	
	УстановитьВидимостьИзменяемогоКлиента();
	// } RGS VShamin 04.05.2016 12:52:32 - 
	
КонецПроцедуры

&НаКлиенте
Процедура ОткрытьПрисоединенныеФайлы(Команда)
	
	ПараметрыФормы = Новый Структура();
	ПараметрыФормы.Вставить("Заявка", Ссылка);
	ПараметрыФормы.Вставить("УзелОбмена", УзелОбмена);
	ОткрытьФорму("Обработка.rgsИнтеграцияСERM.Форма.ФормаЗаявкиПрисоединенныеФайлы", ПараметрыФормы, ЭтаФорма, УникальныйИдентификатор);
	
КонецПроцедуры

// { RGS VShamin 04.05.2016 13:49:03 - 
&НаКлиенте
Процедура Записать(Команда)
	
	Если ПроверкаЗаполненияОбязательныхПолей() Тогда
		Возврат;
	КонецЕсли;
	
	УспешнаяОтправка = ОтправитьЗапросНаСозданиеЗаявки();
	ЭтаФорма.Закрыть(УспешнаяОтправка);
	
КонецПроцедуры // } RGS VShamin 04.05.2016 13:49:03 - 

// { RGS VShamin 04.05.2016 15:16:53 - 
&НаСервере
Функция ОтправитьЗапросНаСозданиеЗаявки()

	WSСсылка = WSСсылки.rgsИнтеграцияСERM;
	ФабрикаXDTOERM = WSСсылка.ПолучитьWSОпределения().ФабрикаXDTO;
	WSПрокси = Обработки.rgsИнтеграцияСERM.СоздатьWSПрокси(УзелОбмена, WSСсылка);
	
	#Область НастройкаКомпонентовОбмена
	КомпонентыОбмена = ОбменДаннымиXDTOСервер.ИнициализироватьКомпонентыОбмена("Отправка");
	КомпонентыОбмена.УзелКорреспондента = УзелОбмена;
	КомпонентыОбмена.ВерсияФорматаОбмена = ОбменДаннымиXDTOСервер.ВерсияФорматаОбменаПриВыгрузке(УзелОбмена);
	ФорматОбмена = ОбменДаннымиXDTOСервер.ФорматОбмена(
		УзелОбмена, КомпонентыОбмена.ВерсияФорматаОбмена
	);
	КомпонентыОбмена.XMLСхема = ФорматОбмена;
	КомпонентыОбмена.МенеджерОбмена = ОбменДаннымиXDTOСервер.МенеджерОбменаВерсииФормата(
		УзелОбмена, КомпонентыОбмена.ВерсияФорматаОбмена
	);
	КомпонентыОбмена.ТаблицаПравилаРегистрацииОбъектов = ОбменДаннымиXDTOСервер.ПравилаРегистрацииОбъектов(УзелОбмена);
	КомпонентыОбмена.СвойстваУзлаПланаОбмена = ОбменДаннымиXDTOСервер.СвойстваУзлаПланаОбмена(УзелОбмена);
	ОбменДаннымиXDTOСервер.ИнициализироватьТаблицыПравилОбмена(КомпонентыОбмена);
	#КонецОбласти
	
	Если ЗначениеЗаполнено(ИзменяемыйКлиент) Тогда
		
		ПравилоКонвертацииКонтрагентОтправка = КомпонентыОбмена.ПравилаКонвертацииОбъектов.Найти("Справочник_Контрагенты_Отправка", "ИмяПКО");
		СтруктураXDTOКлиент = ОбменДаннымиXDTOСервер.ДанныеXDTOИзДанныхИБ(КомпонентыОбмена, ИзменяемыйКлиент, ПравилоКонвертацииКонтрагентОтправка);
		КлиентXDTO = Обработки.rgsИнтеграцияСERM.ПолучитьОбъектXDTO(ФабрикаXDTO, "http://v8.1c.ru/edi/edi_stnd/EnterpriseData/1.0", "Справочник.Контрагенты");
		ТипКлиентаXDTO = Обработки.rgsИнтеграцияСERM.ПолучитьТипОбъектаXDTO(ФабрикаXDTO, "http://v8.1c.ru/edi/edi_stnd/EnterpriseData/1.0", "Справочник.Контрагенты");
		КонтрагентXDTO = ОбменДаннымиXDTOСервер.ОбъектXDTOИзДанныхXDTO(КомпонентыОбмена, СтруктураXDTOКлиент, ТипКлиентаXDTO, КлиентXDTO);
		
		КонтрагентXDTOERM = ТрансляцияXDTOСлужебный.ТранслироватьОбъект(КонтрагентXDTO, ФабрикаXDTOERM);
		
	КонецЕсли;
	
	ПравилоКонвертацииПользовательОтправка = КомпонентыОбмена.ПравилаКонвертацииОбъектов.Найти("Справочник_Пользователи_Отправка", "ИмяПКО");
	СтруктураXDTOПользователь = ОбменДаннымиXDTOСервер.ДанныеXDTOИзДанныхИБ(КомпонентыОбмена, Инициатор, ПравилоКонвертацииПользовательОтправка);
	ПользовательXDTO = Обработки.rgsИнтеграцияСERM.ПолучитьОбъектXDTO(ФабрикаXDTO, "http://v8.1c.ru/edi/edi_stnd/EnterpriseData/1.0", "Справочник.Пользователи");
	ТипПользователяXDTO = Обработки.rgsИнтеграцияСERM.ПолучитьТипОбъектаXDTO(ФабрикаXDTO, "http://v8.1c.ru/edi/edi_stnd/EnterpriseData/1.0", "Справочник.Пользователи");
	ПользовательXDTO = ОбменДаннымиXDTOСервер.ОбъектXDTOИзДанныхXDTO(КомпонентыОбмена, СтруктураXDTOПользователь, ТипПользователяXDTO, ПользовательXDTO);
	
	ПользовательXDTOERM = ТрансляцияXDTOСлужебный.ТранслироватьОбъект(ПользовательXDTO, ФабрикаXDTOERM);
	
	ПользовательXDTOERMКлючевыеСвойстваСФизЛицом = Обработки.rgsИнтеграцияСERM.ПолучитьОбъектXDTO(ФабрикаXDTOERM, "http://v8.1c.ru/edi/edi_stnd/EnterpriseData/1.0", "КлючевыеСвойстваПользователь");
	ПользовательXDTOERMКлючевыеСвойстваСФизЛицом.Ссылка = ПользовательXDTOERM.КлючевыеСвойства.Ссылка;
	ПользовательXDTOERMКлючевыеСвойстваСФизЛицом.Наименование = ПользовательXDTOERM.КлючевыеСвойства.Наименование;
	
	ПараметрыСозданияЗаявки = Обработки.rgsИнтеграцияСERM.ПолучитьОбъектXDTO(ФабрикаXDTOERM, "http://v8.1c.ru/edi/edi_stnd/EnterpriseDataAddition/1.0", "ПараметрыСозданияЗаявки");
	ПараметрыСозданияЗаявки.Наименование = Наименование;
	ПараметрыСозданияЗаявки.ДатаЗаявки = Дата;
	ПараметрыСозданияЗаявки.ВидОперации = ВидОперации;
	Если ЗначениеЗаполнено(ИзменяемыйКлиент) Тогда
		ПараметрыСозданияЗаявки.ИзменяемыйКлиент = КонтрагентXDTOERM.КлючевыеСвойства;
	КонецЕсли;
	ПараметрыСозданияЗаявки.Инициатор = ПользовательXDTOERMКлючевыеСвойстваСФизЛицом;
	ПараметрыСозданияЗаявки.СостояниеЗаявки = СостояниеЗаявки;
	ПараметрыСозданияЗаявки.Комментарий = Комментарий;
	ПараметрыСозданияЗаявки.ИдентификаторКорреспондента = УзелОбмена.Код;
	
	Попытка
		РезультатСозданияЗаявки = WSПрокси.CreateRequest(ПараметрыСозданияЗаявки);
	Исключение
		ТекстОшибки = ОписаниеОшибки();
		Обработки.rgsИнтеграцияСERM.ОбработатьТекстОшибки(ТекстОшибки);
		Возврат Ложь;
	КонецПопытки;
	
	Если НЕ ПустаяСтрока(РезультатСозданияЗаявки) Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(РезультатСозданияЗаявки);
		Возврат Ложь;
	Иначе
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю("Заявка успешно создана!");
		Возврат Истина;
	КонецЕсли;

КонецФункции // } RGS VShamin 04.05.2016 15:16:53 - 

// { RGS VShamin 04.05.2016 14:48:44 - 
&НаКлиенте
Функция ПроверкаЗаполненияОбязательныхПолей()

	Отказ = Ложь;
	
	Если НЕ ЗначениеЗаполнено(Дата) Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю("Не заполнено обязательное поле ""Дата""!");
		Отказ = Истина;
	КонецЕсли;
	
	Если НЕ ЗначениеЗаполнено(ВидОперации) Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю("Не заполнено обязательное поле ""Вид операции""!");
		Отказ = Истина;
	ИначеЕсли (ВидОперации = "ИзменениеРеквизитовОбъекта" ИЛИ ВидОперации = "УдалениеОбъекта"
		ИЛИ ВидОперации = "УдалениеДубликатаОбъекта") И НЕ ЗначениеЗаполнено(ИзменяемыйКлиент) Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю("Не заполнено обязательное поле ""Изменяемый клиент""!");
		Отказ = Истина;
	КонецЕсли;
	
	Возврат Отказ;

КонецФункции // } RGS VShamin 04.05.2016 14:48:44 - 

// { RGS VShamin 11.05.2016 12:45:07 - 
&НаКлиенте
Процедура ВидОперацииПриИзменении(Элемент)
	
	УстановитьВидимостьИзменяемогоКлиента();
	
КонецПроцедуры // } RGS VShamin 11.05.2016 12:45:07 - 

// { RGS VShamin 11.05.2016 12:45:07 - 
&НаСервере
Процедура УстановитьВидимостьИзменяемогоКлиента()
	
	Если НЕ ЗначениеЗаполнено(ВидОперации) ИЛИ ВидОперации = "РегистрацияНовогоОбъекта" Тогда
		Элементы.ИзменяемыйКлиент.Видимость = Ложь;
		ИзменяемыйКлиент = Справочники.Контрагенты.ПустаяСсылка();
	Иначе
		Элементы.ИзменяемыйКлиент.Видимость = Истина;
	КонецЕсли;
	
КонецПроцедуры // } RGS VShamin 11.05.2016 12:45:07 - 
