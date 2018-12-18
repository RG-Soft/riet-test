&НаКлиенте
Перем Organization Экспорт; 
&НаКлиенте
Перем ЭДОбъект Экспорт;
&НаКлиенте
Перем МассивПроверки;
&НаКлиенте
Перем Модуль_Клиент;
&НаКлиенте
Перем ИдентификаторТекущейСтроки;

#Область ПЕРМЕННЫЕ_ПЛАТФОРМЫ

&НаКлиенте
Перем Платформа Экспорт;

&НаСервере
Перем ОбработкаОбъект;

#КонецОбласти

#Область ПРОЦЕДУРЫ_И_ФУНКЦИИ_ПЛАТФОРМЫ

&НаКлиенте
Функция МетодКлиента(ИмяМодуля= "", ИмяМетода, 
		Параметр0= NULL, Параметр1= NULL, Параметр2= NULL, Параметр3= NULL, Параметр4= NULL,
		Параметр5= NULL, Параметр6= NULL, Параметр7= NULL, Параметр8= NULL, Параметр9= NULL) Экспорт
	
	Возврат  Платформа.МетодКлиента(ИмяМодуля, ИмяМетода, 
	Параметр0, Параметр1, Параметр2, Параметр3, Параметр4,
	Параметр5, Параметр6, Параметр7, Параметр8, Параметр9);
	
КонецФункции

&НаКлиенте
Функция МетодСервераБезКонтекста(ИмяМодуля= "", ИмяМетода,
		Параметр0= NULL, Параметр1= NULL, Параметр2= NULL, Параметр3= NULL, Параметр4= NULL, 
		Параметр5= NULL, Параметр6= NULL, Параметр7= NULL, Параметр8= NULL, Параметр9= NULL) Экспорт
	
	Возврат Платформа.МетодСервераБезКонтекста(ИмяМодуля, ИмяМетода,
	Параметр0, Параметр1, Параметр2, Параметр3, Параметр4,
	Параметр5, Параметр6, Параметр7, Параметр8, Параметр9);
	
КонецФункции

&НаСервере
Функция МетодСервера(Знач ИмяМодуля= "", Знач ИмяМетода,
		Параметр0= NULL, Параметр1= NULL, Параметр2= NULL, Параметр3= NULL, Параметр4= NULL, 
		Параметр5= NULL, Параметр6= NULL, Параметр7= NULL, Параметр8= NULL, Параметр9= NULL) Экспорт
	
	Возврат ОбработкаОбъект().МетодСервера(ИмяМодуля, ИмяМетода, 
	Параметр0, Параметр1, Параметр2, Параметр3, Параметр4,
	Параметр5, Параметр6, Параметр7, Параметр8, Параметр9);
	
КонецФункции

&НаСервере
Функция ОбработкаОбъект() Экспорт
	
	Если ОбработкаОбъект = Неопределено Тогда
		ОбработкаОбъект = РеквизитФормыВЗначение("Объект");
	КонецЕсли;
	
	Возврат ОбработкаОбъект;
	
КонецФункции

&НаКлиенте
Функция ОсновнаяФорма(ТекущийВладелецФормы)
	
	Если ТекущийВладелецФормы = Неопределено Тогда
		Возврат Неопределено
	ИначеЕсли Прав(ТекущийВладелецФормы.ИмяФормы, 14) = "Форма_Основная" Тогда
		Возврат ТекущийВладелецФормы;
	Иначе
		Возврат ОсновнаяФорма(ТекущийВладелецФормы.ВладелецФормы);
	КонецЕсли;
	
КонецФункции


&НаСервере
Процедура ПлатформаПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	Параметры.Свойство("ОбъектПараметрыКлиентСервер", Объект.ПараметрыКлиентСервер);
	
КонецПроцедуры

&НаКлиенте
Процедура ПлатформаПриОткрытии(Отказ)
	
	ОсновнаяФорма= ОсновнаяФорма(ВладелецФормы);
	
	Если ОсновнаяФорма <> Неопределено Тогда
		Платформа= ОсновнаяФорма.Платформа;
	КонецЕсли;
		
	Платформа.ПриОткрытииФормыОбработки(ЭтаФорма, Отказ);
	
КонецПроцедуры

&НаКлиенте
Процедура ПлатформаПриЗакрытии()
	
	Платформа.ПриЗакрытииФормыОбработки(ЭтаФорма);
	
КонецПроцедуры

#КонецОбласти

////////////////////////////////////////////////////////////////////////////////
//{ ТЕЛО ФОРМЫ
	
	&НаКлиенте
	Процедура ЗаполнитьПараметрыДокументаВДереве(СтрокаДерева, Document)
		
		СтрокаДерева.ТипДокумента=	МетодКлиента("Модуль_Клиент","ПредставлениеТипаЭД", Document);
		СтрокаДерева.Дата=			Document.DocumentDate;
		
		Если Document.Type = "Invoice" Тогда
			СтрокаДерева.ДатаУчета=	Document.ConfirmationDate;
		Иначе
			СтрокаДерева.ДатаУчета=	Document.Timestamp;
		КонецЕсли;
		
		СтрокаДерева.Номер=							МетодКлиента("Модуль_Клиент","ПредсталениеНомераЭД", Document);
		СтрокаДерева.Сумма= 						МетодКлиента("Модуль_Клиент","ПредставлениеСуммы", Document);
		
		СтрокаДерева.СостояниеДокументооборота=		МетодКлиента("Модуль_Клиент","ПредставлениеСтатуса", Document);
		СтрокаДерева.DocumentId=					Document.DocumentId;
		СтрокаДерева.BoxId=							Document.OrganizationId;
		СтрокаДерева.ПервичныйДокумент=				ПолучитьDocumentID_2_Документ(Document.DocumentId, Document.OrganizationId);;
		СтрокаДерева.Направление=					?(Document.Direction = "Inbound", "Входящий", "Исходящий");
		СтрокаДерева.Продавец=						МетодКлиента("Модуль_Клиент","ПредставлениеПродавца", Document);
		СтрокаДерева.Покупатель=					МетодКлиента("Модуль_Клиент","ПредставлениеПокупателя", Document);
		
		Department=	Document.Department;
		СтрокаДерева.Подразделение=					?(Department<>неопределено, Document.Department.Name, "");
		
	КонецПроцедуры
	
	&НаКлиенте
	Функция ПолучитьВершинуДеревоDocument(Document)
		
		ТекущийDocument=	Document;
		Если ТекущийDocument.InitialDocumentIds.Count > 0 Тогда
			Если МассивПроверки.Найти(ТекущийDocument.DocumentID) = Неопределено Тогда
				МассивПроверки.Добавить(ТекущийDocument.DocumentID);
				ParentDocumentId=	ТекущийDocument.InitialDocumentIds.GetItem(0);
				ТекущийDocument=	ТекущийDocument.Organization.GetDocumentById(ParentDocumentId);
			КонецЕсли;
		КонецЕсли;
		
		Возврат ТекущийDocument;
		
	КонецФункции
	
	&НаКлиенте
	Процедура ОбработатьУзелДерева(Document, ParentId, РодительскаяСтрока = Неопределено)
		
		Если Document = Неопределено ИЛИ НЕ МассивПроверки.Найти(Document.DocumentID) = Неопределено Тогда
			Возврат;
		КонецЕсли;
		
		МассивПроверки.Добавить(Document.DocumentID);
		
		Если РодительскаяСтрока = Неопределено Тогда
			Строка=	ДеревоДокументов.ПолучитьЭлементы().Добавить();
		Иначе
			Строка=	РодительскаяСтрока.ПолучитьЭлементы().Добавить();
		КонецЕсли;
		
		строка.IsDeleted = 	Document.isDeleted;
		
		строка.DocumentID = Document.DocumentID;
		
		Если строка.DocumentID = ЭДОбъект.DocumentID Тогда
			Строка.ЭтоДокументИнициализатор=	Истина;
			ИдентификаторТекущейСтроки=			Строка.ПолучитьИдентификатор();
		КонецЕсли;
		
		ЗаполнитьПараметрыДокументаВДереве(строка, Document);
		
		Для Индекс = 0 По Document.SubordinateDocumentIds.Count - 1 Цикл
			стрSubordinateId=	Document.SubordinateDocumentIds.GetItem(Индекс);
			ОбработатьУзелДерева(Document.Organization.GetDocumentById(стрSubordinateId), Document.DocumentId, Строка);
		КонецЦикла;
		
		Для Индекс = 0 По Document.InitialDocumentIds.Count - 1 Цикл
			стрParentID=	Document.InitialDocumentIds.GetItem(Индекс);
			ОбработатьУзелДерева(Document.Organization.GetDocumentById(стрParentID), Document.DocumentId);	
		КонецЦикла;
		
	КонецПроцедуры
	
	&НаКлиенте
	Процедура ЗаполнитьДеревоСвязейДокументов()
		
		МассивПроверки.Очистить();
		
		ДеревоДокументов.ПолучитьЭлементы().Очистить();
		
		ВершинаДерева=	ПолучитьВершинуДеревоDocument(ЭДОбъект);
		
		МассивПроверки.Очистить();
		
		ОбработатьУзелДерева(ВершинаДерева, "");
		
		Для каждого СтрокаДерева Из ДеревоДокументов.ПолучитьЭлементы() Цикл
			Элементы.ТаблицаДокументов.Развернуть(СтрокаДерева.ПолучитьИдентификатор(), Истина);
		КонецЦикла;
		
		Элементы.ТаблицаДокументов.ТекущаяСтрока=	ИдентификаторТекущейСтроки;
		
	КонецПроцедуры
	
	&НаКлиенте
	Функция ПроверитьОтметки(СтрокиДерева)
		
		ЕстьОтметки=	Ложь;
		Для каждого СтрокаДерева Из СтрокиДерева Цикл
			Если СтрокаДерева.Вкл Тогда
				Возврат Истина;
			КонецЕсли;
			ЕстьОтметки= ПроверитьОтметки(СтрокаДерева.ПолучитьЭлементы());
		КонецЦикла;
		
		Возврат ЕстьОтметки;
		
	КонецФункции
	
	&НаКлиенте
	Процедура УдалитьДокументыСтрок(МассивДокументов, СтрокиДерева)
		
		Для Каждого СтрокаДерева из СтрокиДерева Цикл
			Если СтрокаДерева.Вкл Тогда	
				
				ПараметрУдаляемогоДокумента=	Новый Структура();
				ПараметрУдаляемогоДокумента.Вставить("DocumentId", 	СтрокаДерева.DocumentId);
				ПараметрУдаляемогоДокумента.Вставить("BoxID", 		СтрокаДерева.BoxID);
				
				МассивДокументов.Добавить(ПараметрУдаляемогоДокумента);
				Если ЗначениеЗаполнено(СтрокаДерева.ПервичныйДокумент) Тогда
					Установить_DocumentID_Для_Документ(СтрокаДерева.ПервичныйДокумент,,);
				КонецЕсли;
				
				Document=	Платформа.ПараметрыКлиент.КонтекстРаботаССерверомДиадок.DiadocConnection.GetOrganizationById(СтрокаДерева.BoxID).GetDocumentById(СтрокаДерева.DocumentID);
				
				Если НЕ Document.IsDeleted Тогда
					Попытка
						Document.Delete();
					Исключение
						
						ОписаниеОшибки=	ОписаниеОшибки();
						ТекстОшибки=	ОписаниеОшибки;
						Если Найти(ТекстОшибки, "is already delete") Тогда
							ТекстОшибки=	"Документ " + МетодКлиента("Модуль_Клиент","ПредставлениеЭД", Document) + " уже был удален.";
						Иначе
							ТекстОшибки=	"Ошибка удаления документа";
						КонецЕсли;
						
						ПараметрыФормы=	Новый Структура();
						ПараметрыФормы.Вставить("Заголовок", 		"Ошибка удаления");
						ПараметрыФормы.Вставить("ОписаниеОшибки", 	ТекстОшибки);
						ПараметрыФормы.Вставить("Подробности", 		ОписаниеОшибки);
						
						МетодКлиента(,"ОткрытьФормуОбработкиМодально", "Форма_ВыводОшибки", ПараметрыФормы, ЭтаФорма);

					КонецПопытки;
					
					СтрокаДерева.IsDeleted=	Истина;
					
				КонецЕсли;
			КонецЕсли;
			УдалитьДокументыСтрок(МассивДокументов, СтрокаДерева.ПолучитьЭлементы());
		КонецЦикла
		
	КонецПроцедуры
	
	&НаКлиенте
	Процедура Удалить(Команда)
		
		ЕстьОтметки=	ПроверитьОтметки(ДеревоДокументов.ПолучитьЭлементы());
		Если НЕ ЕстьОтметки Тогда
			СообщениеПользователю=			Новый СообщениеПользователю;
			СообщениеПользователю.Текст=	"Не выбрано документов для удаления";
			СообщениеПользователю.Сообщить();
			Возврат;
		КонецЕсли;
		
		Оповещение=	Новый ОписаниеОповещения("ОбработчикУдалитьДокументы", ЭтаФорма);
		ПоказатьВопрос(Оповещение, "Вы действительно хотите удалить выбранные документы?", РежимДиалогаВопрос.ДаНет, 120, КодВозвратаДиалога.Нет, Платформа.ПараметрыКлиент.СловарьWL.НаименованиеСистемы, КодВозвратаДиалога.Нет);
		
	КонецПроцедуры
	
//} ТЕЛО ФОРМЫ
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
//{ СЛУЖЕБНЫЕ ПРОЦЕДУРЫ И ФУНКЦИИ
	
	&НаКлиенте
	Функция ПолучитьРасширениеФайлаДиадок(ИмяФайла)
		КолСим = СтрДлина(ИмяФайла);
		Для ИндЦикла = 1 По КолСим Цикл
			Инд = КолСим + 1 - ИндЦикла;
			Если Сред(ИмяФайла, Инд, 1) = "." Тогда
				Возврат ?(КолСим = Инд, 0, Сред(ИмяФайла, Инд + 1, КолСим - Инд));
			КонецЕсли;
		КонецЦикла;
	КонецФункции
	
	&НаСервере
	Функция ПолучитьDocumentID_2_Документ(DocumentID, BoxID)
		
		Возврат МетодСервера(,"DocumentID_2_Документ", DocumentID, BoxID);
		
	КонецФункции
	
	&НаКлиенте
	Процедура СформироватьПечатнуюФормуПоФайлуДиадок()
		
		Состояние("Формирование печатной формы документа " + Платформа.ПараметрыКлиент.СловарьWL.НаименованиеСистемы);
		
		ТекущиеДанные=	Элементы.ТаблицаДокументов.ТекущиеДанные;
		
		Если ТекущиеДанные = Неопределено Тогда
			ПоказатьПредупреждение(, "Выберите документ.", 120,Платформа.ПараметрыКлиент.СловарьWL.НаименованиеСистемы);
			Возврат;
		КонецЕсли;
		
		Document=	Платформа.ПараметрыКлиент.КонтекстРаботаССерверомДиадок.DiadocConnection.GetOrganizationById(ТекущиеДанные.BoxID).GetDocumentById(ТекущиеДанные.DocumentID);
		
		ПараметрыФормы=	Новый Структура;
		
		Если Document.Department <> Неопределено Тогда
			ПараметрыФормы.Вставить("DepartmentKpp", 		Document.Department.Kpp);
			ПараметрыФормы.Вставить("DepartmentId", 		Document.Department.Id);
		КонецЕсли;
		
		ПараметрыФормы.Вставить("BoxID", 					Document.OrganizationID);
		ПараметрыФормы.Вставить("CounteragentBoxID", 		Document.Counteragent.ID);
		ПараметрыФормы.Вставить("РасширениеФайлаДиадок", 	ПолучитьРасширениеФайлаДиадок(ЭДОбъект.FileName));
		ПараметрыФормы.Вставить("DocumentType",				Document.Type);
		ПараметрыФормы.Вставить("Документ1С", 				ТекущиеДанные.ПервичныйДокумент);
		ПараметрыФормы.Вставить("ДопСведения", 				"");
		ПараметрыФормы.Вставить("НомерЗаказа", 				"");
		
		ИмяФормыПросмотра=	МетодКлиента("Модуль_Клиент","ПолучитьИмяФормыДокумента", Document);
		ФормаПросмотра=		МетодКлиента(,"ПолучитьФормуОбработки", ИмяФормыПросмотра, ПараметрыФормы, ЭтаФорма, СокрЛП(Document.DocumentID) + "/" + СокрЛП(Document.OrganizationID));
		
		ФормаПросмотра.ЭДОбъект= Document;
		
		ОткрытьФорму(ФормаПросмотра);
		
		Состояние("Формирование печатной формы завершено");

	КонецПроцедуры
	
	&НаКлиенте
	Процедура ОткрытьКарточкуДокумента(Команда)
		
		СформироватьПечатнуюФормуПоФайлуДиадок();
		
	КонецПроцедуры
	
	&НаКлиенте
	Процедура ТаблицаДокументовВыбор(Элемент, ВыбраннаяСтрока, Поле, СтандартнаяОбработка)
		
		СформироватьПечатнуюФормуПоФайлуДиадок();
		
	КонецПроцедуры
	
	&НаСервере
	Процедура Установить_DocumentID_Для_Документ(ДокументССылка, DocumentId, OrganizationId)
		МетодСервера(,"Установить_DocumentID_Для_Документ", ДокументССылка, DocumentId, OrganizationId);
	КонецПроцедуры
	
//} СЛУЖЕБНЫЕ ПРОЦЕДУРЫ И ФУНКЦИИ
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
//{ УПРАВЛЕНИЕ ФОРМОЙ И ОБРАБОТКА СОБЫТИЙ
	
	&НаСервере
	Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
		
		ПлатформаПриСозданииНаСервере(Отказ, СтандартнаяОбработка);
		
	КонецПроцедуры
	
	&НаКлиенте
	Процедура УправлениеФормой()
		
		Если Параметры.Режим = "Удаление" Тогда
			Заголовок=	"Удаление документов в " + Платформа.ПараметрыКлиент.СловарьWL.КраткоеНаименованиеСистемыПредложныйПадеж;
			
			Элементы.ТаблицаДокументов.КоманднаяПанель.ПодчиненныеЭлементы.ТаблицаДокументовУдалить.Видимость=					Истина;
			Элементы.ТаблицаДокументов.КоманднаяПанель.ПодчиненныеЭлементы.ТаблицаДокументовУдалить.Доступность=				Истина;
			Элементы.ТаблицаДокументов.КонтекстноеМеню.ПодчиненныеЭлементы.ТаблицаДокументовУдалитьКонтекст.Видимость=			Истина;
			Элементы.ТаблицаДокументов.КонтекстноеМеню.ПодчиненныеЭлементы.ТаблицаДокументовУдалитьКонтекст.Доступность=		Истина;
			
			Элементы.ТаблицаДокументов.КоманднаяПанель.ПодчиненныеЭлементы.ТаблицаДокументовСнятьУстановитьПометки.Видимость=	Истина;
			Элементы.ТаблицаДокументов.КоманднаяПанель.ПодчиненныеЭлементы.ТаблицаДокументовСнятьУстановитьПометки.Доступность=	Истина;
			
			Элементы.ТаблицаДокументов.ПодчиненныеЭлементы.ТаблицаДокументовВкл.Видимость=										Истина;
			Элементы.ТаблицаДокументов.ПодчиненныеЭлементы.ТаблицаДокументовВкл.Доступность=									Истина;
			
		Иначе
			Заголовок=	"Структура подчиненности";
			
		КонецЕсли;
		
	КонецПроцедуры
	
	&НаКлиенте
	Процедура ПриОткрытии(Отказ)
		
		ПлатформаПриОткрытии(Отказ);
		
		УправлениеФормой();
		
		ЗаполнитьДеревоСвязейДокументов();
		
	КонецПроцедуры
	
	&НаКлиенте
	Процедура Обновить(Команда)
		
		ЗаполнитьДеревоСвязейДокументов();
		
	КонецПроцедуры
	
	&НаКлиенте
	Процедура СнятьУстановитьПометки(Пометка, КоллекцияСтрокДерева)
		
		Для Каждого СтрокаСпискаДокументов Из КоллекцияСтрокДерева Цикл
			СтрокаСпискаДокументов.Вкл=	Пометка;
			СнятьУстановитьПометки(Пометка, СтрокаСпискаДокументов.ПолучитьЭлементы());
		КонецЦикла;
		
	КонецПроцедуры
	
	&НаКлиенте
	Функция ПроверитьПометкиПодчиненныхСтрок(КоллекцияСтрок)
		
		Для каждого СтрокаДерева Из КоллекцияСтрок Цикл
			Если СтрокаДерева.Вкл Тогда
				Возврат Истина;
			Иначе
				Возврат ПроверитьПометкиПодчиненныхСтрок(СтрокаДерева.ПолучитьЭлементы());
			КонецЕсли;
		КонецЦикла;
		
		Возврат Ложь;
		
	КонецФункции
	
	&НаКлиенте
	Процедура УстановитьКартинкуИЗаголовокКнопкиПометки(Пометка)
		
		Если Пометка Тогда
			Элементы.ТаблицаДокументов.КоманднаяПанель.ПодчиненныеЭлементы.ТаблицаДокументовСнятьУстановитьПометки.Картинка= 	БиблиотекаКартинок.УстановитьФлажки;
			Элементы.ТаблицаДокументов.КоманднаяПанель.ПодчиненныеЭлементы.ТаблицаДокументовСнятьУстановитьПометки.Заголовок=	"Снять пометку со всех документов";
		Иначе
			Элементы.ТаблицаДокументов.КоманднаяПанель.ПодчиненныеЭлементы.ТаблицаДокументовСнятьУстановитьПометки.Картинка= 	БиблиотекаКартинок.СнятьФлажки;
			Элементы.ТаблицаДокументов.КоманднаяПанель.ПодчиненныеЭлементы.ТаблицаДокументовСнятьУстановитьПометки.Заголовок=	"Пометить все документы";
		КонецЕсли;
		
	КонецПроцедуры
	
	&НаКлиенте
	Процедура ОбработатьПометки(СбросПометок = Ложь)
		
		Если Элементы.ТаблицаДокументов.КоманднаяПанель.ПодчиненныеЭлементы.ТаблицаДокументовСнятьУстановитьПометки.Картинка= 	БиблиотекаКартинок.СнятьФлажки 
			И НЕ СбросПометок Тогда
			УстановитьКартинкуИЗаголовокКнопкиПометки(Истина);
			СнятьУстановитьПометки(Истина, ДеревоДокументов.ПолучитьЭлементы());
		Иначе
			УстановитьКартинкуИЗаголовокКнопкиПометки(Ложь);
			СнятьУстановитьПометки(Ложь, ДеревоДокументов.ПолучитьЭлементы());
		КонецЕсли;
		
	КонецПроцедуры
	
	&НаКлиенте
	Процедура СнятьУстановитьПометкиКоманда(Команда)
		
		ОбработатьПометки();
		
	КонецПроцедуры
	
	&НаКлиенте
	Процедура ПроверитьПометкиСтрок(КоллекцияСтрок, КоличествоПомеченных, КоличествоНеПомеченных)
		
		Для каждого СтрокаДерева Из КоллекцияСтрок Цикл
			
			Если СтрокаДерева.Вкл Тогда
				КоличествоПомеченных=	КоличествоПомеченных + 1;
			Иначе
				КоличествоНеПомеченных=	КоличествоНеПомеченных + 1;
			КонецЕсли;
			
			ПроверитьПометкиСтрок(СтрокаДерева.ПолучитьЭлементы(), КоличествоПомеченных, КоличествоНеПомеченных);
			
		КонецЦикла;
		
	КонецПроцедуры
	
	&НаКлиенте
	Функция ПроверитьПометкиДокументов()
		
		СтруктураИзменений=	Новый Структура;
		СтруктураИзменений.Вставить("НужноМенять", 	Ложь);
		СтруктураИзменений.Вставить("Вкл", 			Ложь);
		
		КоличествоПомеченных=	0;
		КоличествоНеПомеченных=	0;
		ПроверитьПометкиСтрок(ДеревоДокументов.ПолучитьЭлементы(), КоличествоПомеченных, КоличествоНеПомеченных);
		
		Если (КоличествоПомеченных > 0 И КоличествоНеПомеченных = 0)
			ИЛИ (КоличествоНеПомеченных > 0 И КоличествоПомеченных = 0) Тогда
			СтруктураИзменений=	Новый Структура;
			СтруктураИзменений.Вставить("НужноМенять", 	Истина);
			СтруктураИзменений.Вставить("Вкл", 			?(КоличествоПомеченных > 0, Истина, Ложь));
		КонецЕсли;
		
		Возврат СтруктураИзменений;
		
	КонецФункции
	
	&НаКлиенте
	Процедура ОбработатьПодчиненныеСтрокиДерева(Пометка, СтрокиДерева)
		
		Для каждого СтрокаДерева Из СтрокиДерева Цикл
			СтрокаДерева.Вкл=	Пометка;
			ОбработатьПодчиненныеСтрокиДерева(Пометка, СтрокаДерева.ПолучитьЭлементы())
		КонецЦикла;
		
	КонецПроцедуры
	
	&НаКлиенте
	Процедура ТаблицаДокументовВклПриИзменении(Элемент)
		
		//ТекущиеДанные=	Элементы.ТаблицаДокументов.ТекущиеДанные;
		//Пометка=		ТекущиеДанные.Вкл;
		//ОбработатьПодчиненныеСтрокиДерева(Пометка, ТекущиеДанные.ПолучитьЭлементы());
		
		СтруктураИзменений=	ПроверитьПометкиДокументов();
		
		Если СтруктураИзменений.НужноМенять Тогда
			УстановитьКартинкуИЗаголовокКнопкиПометки(СтруктураИзменений.Вкл);
		КонецЕсли;
		
	КонецПроцедуры
	
	&НаКлиенте
	Процедура ОбработкаОповещения(ИмяСобытия, ПараметрыОповещения, Источник) Экспорт
		
		Если ИмяСобытия = "УдалениеДокументов" Тогда
			ЗаполнитьДеревоСвязейДокументов();
		КонецЕсли;
		
	КонецПроцедуры
	
	&НаКлиенте
	Процедура ОбработчикУдалитьДокументы(РезультатВопроса, ДополнительныеПараметры) Экспорт
		
		Если РезультатВопроса = КодВозвратаДиалога.Да Тогда
			МассивДокументов=	Новый Массив;
			УдалитьДокументыСтрок(МассивДокументов, ДеревоДокументов.ПолучитьЭлементы());
			МетодКлиента(,"ОповеститьФормы", "УдалениеДокументов", МассивДокументов);
		КонецЕсли;
		
	КонецПроцедуры

	&НаКлиенте
	Процедура ПриЗакрытии()
		
		ПлатформаПриЗакрытии();
		
		Organization=					Неопределено;
		ЭДОбъект=						Неопределено;
		МассивПроверки=					Неопределено;
		Модуль_Клиент=					Неопределено;
		ИдентификаторТекущейСтроки=		Неопределено;
		
	КонецПроцедуры
	
//} УПРАВЛЕНИЕ ФОРМОЙ И ОБРАБОТКА СОБЫТИЙ
////////////////////////////////////////////////////////////////////////////////


МассивПроверки=	Новый Массив();