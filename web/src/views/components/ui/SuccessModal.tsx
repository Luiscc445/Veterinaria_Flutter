import { ReactNode } from 'react'

interface SuccessModalProps {
  isOpen: boolean
  onClose: () => void
  title: string
  message: string
  details?: { label: string; value: string }[]
  icon?: ReactNode
}

export default function SuccessModal({
  isOpen,
  onClose,
  title,
  message,
  details,
  icon
}: SuccessModalProps) {
  if (!isOpen) return null

  return (
    <>
      {/* Overlay */}
      <div
        className="fixed inset-0 bg-black bg-opacity-50 transition-opacity z-40"
        onClick={onClose}
      ></div>

      {/* Modal */}
      <div className="fixed inset-0 z-50 overflow-y-auto pointer-events-none">
        <div className="flex min-h-full items-center justify-center p-4">
          <div
            className="relative bg-white rounded-2xl shadow-2xl max-w-md w-full pointer-events-auto transform transition-all"
            onClick={(e) => e.stopPropagation()}
          >
            {/* Icono de éxito */}
            <div className="flex flex-col items-center pt-8 pb-4">
              {icon || (
                <div className="w-20 h-20 bg-green-100 rounded-full flex items-center justify-center mb-4 animate-bounce">
                  <svg
                    className="w-12 h-12 text-green-600"
                    fill="none"
                    stroke="currentColor"
                    viewBox="0 0 24 24"
                  >
                    <path
                      strokeLinecap="round"
                      strokeLinejoin="round"
                      strokeWidth={3}
                      d="M5 13l4 4L19 7"
                    />
                  </svg>
                </div>
              )}

              <h3 className="text-2xl font-bold text-gray-900 mb-2">{title}</h3>
              <p className="text-gray-600 text-center px-6">{message}</p>
            </div>

            {/* Detalles */}
            {details && details.length > 0 && (
              <div className="bg-gray-50 px-8 py-6 space-y-3">
                {details.map((detail, index) => (
                  <div key={index} className="flex justify-between items-start">
                    <span className="text-sm font-medium text-gray-700">
                      {detail.label}:
                    </span>
                    <span className="text-sm text-gray-900 font-semibold ml-4 text-right">
                      {detail.value}
                    </span>
                  </div>
                ))}
              </div>
            )}

            {/* Botón */}
            <div className="px-8 py-6">
              <button
                onClick={onClose}
                className="w-full bg-green-600 text-white py-3 rounded-lg font-semibold hover:bg-green-700 transition-colors focus:outline-none focus:ring-2 focus:ring-green-500 focus:ring-offset-2"
              >
                Entendido
              </button>
            </div>
          </div>
        </div>
      </div>
    </>
  )
}
