#import "ViewController.h"
#import "Record+CoreDataClass.h"  // Сгенерированный класс CoreData

@interface ViewController ()

@property (assign, nonatomic) BOOL isSelectingFrom;  // YES = Откуда, NO = Куда

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 1. Настройка карты
    [self setupMapView];
    
    // 2. Настройка геолокации
    [self setupLocationManager];
    
    // 3. Получение контекста CoreData
    [self setupCoreData];
    
    // 4. Загрузка тестовых данных
    [self loadSampleData];
    
    // 5. Настройка таблицы
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    // 6. Настройка полей ввода
    self.cityFromField.delegate = self;
    self.cityToField.delegate = self;
}

#pragma mark - Setup Methods

- (void)setupMapView {
    self.mapView.delegate = self;
    self.mapView.showsUserLocation = YES;
    
    // Длинное нажатие на карту для выбора города
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]
                                               initWithTarget:self
                                               action:@selector(handleLongPress:)];
    [self.mapView addGestureRecognizer:longPress];
}

- (void)setupLocationManager {
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    [self.locationManager requestWhenInUseAuthorization];
    [self.locationManager startUpdatingLocation];
}

- (void)setupCoreData {
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    self.managedObjectContext = appDelegate.persistentContainer.viewContext;
}

#pragma mark - CoreData Operations

- (void)loadSampleData {
    // Проверяем, есть ли уже данные
    NSFetchRequest *checkRequest = [NSFetchRequest fetchRequestWithEntityName:@"Record"];
    NSError *error = nil;
    NSInteger count = [self.managedObjectContext countForFetchRequest:checkRequest error:&error];
    
    if (count > 0) {
        return; // Данные уже есть
    }
    
    // Тестовые рейсы
    NSArray *sampleFlights = @[
        @{@"cityFrom": @"Москва", @"cityTo": @"Доха", @"company": @"Qatar Airways", @"price": @450.0},
        @{@"cityFrom": @"Москва", @"cityTo": @"Доха", @"company": @"Aeroflot", @"price": @380.0},
        @{@"cityFrom": @"Минск", @"cityTo": @"Стамбул", @"company": @"Turkish Airlines", @"price": @220.0},
        @{@"cityFrom": @"Минск", @"cityTo": @"Стамбул", @"company": @"Belavia", @"price": @195.0},
        @{@"cityFrom": @"Киев", @"cityTo": @"Варшава", @"company": @"LOT Polish Airlines", @"price": @150.0}
    ];
    
    for (NSDictionary *flightData in sampleFlights) {
        Record *flight = [NSEntityDescription insertNewObjectForEntityForName:@"Record"
                                                       inManagedObjectContext:self.managedObjectContext];
        flight.cityFrom = flightData[@"cityFrom"];
        flight.cityTo = flightData[@"cityTo"];
        flight.aviaCompany = flightData[@"company"];
        flight.price = [flightData[@"price"] floatValue];
    }
    
    [self.managedObjectContext save:&error];
    if (error) {
        NSLog(@"Ошибка сохранения: %@", error.localizedDescription);
    }
}

- (void)searchFlights {
    if (self.cityFromField.text.length == 0 || self.cityToField.text.length == 0) {
        [self showAlert:@"Пожалуйста, выберите города отправления и назначения"];
        return;
    }
    
    // Запрос к CoreData
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Record"];
    request.predicate = [NSPredicate predicateWithFormat:@"cityFrom == %@ AND cityTo == %@",
                         self.cityFromField.text, self.cityToField.text];
    
    NSError *error = nil;
    self.flightsArray = [self.managedObjectContext executeFetchRequest:request error:&error];
    
    if (error) {
        NSLog(@"Ошибка поиска: %@", error.localizedDescription);
        self.flightsArray = @[];
    }
    
    [self.tableView reloadData];
    
    if (self.flightsArray.count == 0) {
        [self showAlert:@"Рейсы не найдены"];
    }
}

#pragma mark - MapView Gesture

- (void)handleLongPress:(UILongPressGestureRecognizer *)gesture {
    if (gesture.state != UIGestureRecognizerStateBegan) return;
    
    // Получаем координаты точки нажатия
    CGPoint point = [gesture locationInView:self.mapView];
    CLLocationCoordinate2D coordinate = [self.mapView convertPoint:point toCoordinateFromView:self.mapView];
    CLLocation *location = [[CLLocation alloc] initWithLatitude:coordinate.latitude
                                                      longitude:coordinate.longitude];
    
    // Геокодирование: координаты → название города
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray<CLPlacemark *> *placemarks, NSError *error) {
        if (error) {
            [self showAlert:@"Не удалось определить город"];
            return;
        }
        
        CLPlacemark *placemark = [placemarks firstObject];
        NSString *city = placemark.locality;
        
        if (!city) {
            [self showAlert:@"Город не найден"];
            return;
        }
        
        // Записываем город в выбранное поле
        if (self.isSelectingFrom) {
            self.cityFromField.text = city;
        } else {
            self.cityToField.text = city;
        }
        
        // Добавляем аннотацию на карту
        MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
        annotation.coordinate = coordinate;
        annotation.title = city;
        [self.mapView addAnnotation:annotation];
    }];
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (textField == self.cityFromField) {
        self.isSelectingFrom = YES;
        [self showAlert:@"Нажмите и удерживайте на карте, чтобы выбрать город отправления"];
    } else if (textField == self.cityToField) {
        self.isSelectingFrom = NO;
        [self showAlert:@"Нажмите и удерживайте на карте, чтобы выбрать город назначения"];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.flightsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FlightCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"FlightCell"];
    }
    
    Record *flight = self.flightsArray[indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@ - %@", flight.aviaCompany, flight.cityTo];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Цена: $%.2f", flight.price];
    
    return cell;
}

#pragma mark - IBActions

- (IBAction)findButtonTapped:(id)sender {
    [self searchFlights];
}

#pragma mark - Helper Methods

- (void)showAlert:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Информация"
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

@end
