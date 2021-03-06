
&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	НастроитьЭлементыОтбора();
	
КонецПроцедуры

&НаСервере
Процедура НастроитьЭлементыОтбора()
	
	//настроим отбор
	ТекущийПользователь = Пользователи.ТекущийПользователь();
	
	Если Не РГСофтСерверПовтИспСеанс.ПолучитьЗначениеПоУмолчанию(ТекущийПользователь, "УчетПоВсемОрганизациям") Тогда
		
		ОсновнаяОрганизация = РГСофтСерверПовтИспСеанс.ПолучитьЗначениеПоУмолчанию(ТекущийПользователь, "ОсновнаяОрганизация");
		
		ОбщегоНазначенияКлиентСервер.УстановитьЭлементОтбора(Список.Отбор,
													"Организация",
													ОсновнаяОрганизация,
													ВидСравненияКомпоновкиДанных.Равно,
													,Истина,
													РежимОтображенияЭлементаНастройкиКомпоновкиДанных.Авто);
	КонецЕсли;
												
	Если Не РГСофтСерверПовтИспСеанс.ПолучитьЗначениеПоУмолчанию(ТекущийПользователь, "УчетПоВсемОтветственным") Тогда
		
		ОсновнойОтветственный = РГСофтСерверПовтИспСеанс.ПолучитьЗначениеПоУмолчанию(ТекущийПользователь, "ОсновнойОтветственный");
		
		ОбщегоНазначенияКлиентСервер.УстановитьЭлементОтбора(Список.Отбор,
													"Ответственный",
													ОсновнойОтветственный,
													ВидСравненияКомпоновкиДанных.Равно,
													,Истина,
													РежимОтображенияЭлементаНастройкиКомпоновкиДанных.Авто);
	КонецЕсли;
	
	Если Не РГСофтСерверПовтИспСеанс.ПолучитьЗначениеПоУмолчанию(ТекущийПользователь, "УчетПоВсемИнвойсинговымЦентрам") Тогда
		
		ОсновнойИнвойсинговыйЦентр = РГСофтСерверПовтИспСеанс.ПолучитьЗначениеПоУмолчанию(ТекущийПользователь, "ОсновнойИнвойсинговыйЦентр");
		СписокИнвойсинговыхЦентров = Новый СписокЗначений;
		СписокИнвойсинговыхЦентров.Добавить(ОсновнойИнвойсинговыйЦентр);
		СписокИнвойсинговыхЦентров.Добавить(Справочники.ИнвойсинговыеЦентры.ПустаяСсылка());
		
		ОбщегоНазначенияКлиентСервер.УстановитьЭлементОтбора(Список.Отбор,
													"ИнвойсинговыйЦентр",
													СписокИнвойсинговыхЦентров,
													ВидСравненияКомпоновкиДанных.ВСписке,
													,Истина,
													РежимОтображенияЭлементаНастройкиКомпоновкиДанных.Авто);
	КонецЕсли;

	Если Параметры.Свойство("Организация") Тогда 
		 ОбщегоНазначенияКлиентСервер.УстановитьЭлементОтбора(Список.Отбор,
													"Организация",
													Параметры.Организация,
													ВидСравненияКомпоновкиДанных.Равно,
													,Истина,
													РежимОтображенияЭлементаНастройкиКомпоновкиДанных.Авто);
	КонецЕсли;
	
	//Добавила Федотова Л., РГ-Софт, 26.02.13, вопрос SLI-0003369 ->
	Если Параметры.Свойство("Контрагент") Тогда 
		 ОбщегоНазначенияКлиентСервер.УстановитьЭлементОтбора(Список.Отбор,
													"Контрагент",
													Параметры.Контрагент,
													ВидСравненияКомпоновкиДанных.Равно,
													,Истина,
													РежимОтображенияЭлементаНастройкиКомпоновкиДанных.Авто);
	КонецЕсли;

	Если Параметры.Свойство("ДоговорКонтрагента") Тогда 
		 ОбщегоНазначенияКлиентСервер.УстановитьЭлементОтбора(Список.Отбор,
													"ДоговорКонтрагента",
													Параметры.ДоговорКонтрагента,
													ВидСравненияКомпоновкиДанных.Равно,
													,Истина,
													РежимОтображенияЭлементаНастройкиКомпоновкиДанных.Авто);
	КонецЕсли;
	
	Если Параметры.Свойство("ВидОперации") Тогда 
		 ОбщегоНазначенияКлиентСервер.УстановитьЭлементОтбора(Список.Отбор,
													"ВидОперации",
													Параметры.ВидОперации,
													ВидСравненияКомпоновкиДанных.Равно,
													,Истина,
													РежимОтображенияЭлементаНастройкиКомпоновкиДанных.Авто);
	КонецЕсли;
    //<-
	
КонецПроцедуры

