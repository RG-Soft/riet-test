
&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	НастроитьЭлементыОтбора();
	
КонецПроцедуры

&НаСервере
Процедура НастроитьЭлементыОтбора()
	
	ТекущийПользователь = Пользователи.ТекущийПользователь();
	        													
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
												
КонецПроцедуры



