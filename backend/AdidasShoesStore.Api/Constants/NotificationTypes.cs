namespace AdidasShoesStore.Api.Constants;

public static class NotificationTypes
{
    public const string OrderPlaced = "OrderPlaced";
    public const string NewOrder = "NewOrder";
    public const string NewCODOrder = "NewCODOrder";
    public const string PendingPaymentOrder = "PendingPaymentOrder";
    public const string PaymentPending = "PaymentPending";
    public const string PaymentSuccess = "PaymentSuccess";
    public const string PaymentFailed = "PaymentFailed";
    public const string PaymentExpired = "PaymentExpired";
    public const string OrderConfirmed = "OrderConfirmed";
    public const string ShipmentCreated = "ShipmentCreated";
    public const string Shipping = "Shipping";
    public const string Delivered = "Delivered";
    public const string Completed = "Completed";
    public const string RefundRequestCreated = "RefundRequestCreated";
    public const string RefundApproved = "RefundApproved";
    public const string RefundRejected = "RefundRejected";
    public const string RefundCompleted = "RefundCompleted";
    public const string ReturnRequestCreated = "ReturnRequestCreated";
    public const string ReturnApproved = "ReturnApproved";
    public const string ReturnRejected = "ReturnRejected";
    public const string ReturnShipped = "ReturnShipped";
    public const string ReturnReceived = "ReturnReceived";
    public const string ReturnRefunded = "ReturnRefunded";
    public const string ReturnWaitingConfirmation = "ReturnWaitingConfirmation";
    public const string Deal = "Deal";
    public const string Discount = "Discount";
    public const string FlashSale = "FlashSale";
    public const string Voucher = "Voucher";
    public const string WishlistPriceDrop = "WishlistPriceDrop";
    public const string CartPriceDrop = "CartPriceDrop";
}
