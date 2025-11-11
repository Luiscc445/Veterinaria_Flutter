import { ReactNode, useEffect } from 'react'
import Button from './Button'

interface ModalProps {
  isOpen: boolean
  onClose: () => void
  title: string
  children: ReactNode
  footer?: ReactNode
  size?: 'sm' | 'md' | 'lg' | 'xl'
}

export default function Modal({ isOpen, onClose, title, children, footer, size = 'md' }: ModalProps) {
  useEffect(() => {
    if (isOpen) {
      document.body.style.overflow = 'hidden'
    } else {
      document.body.style.overflow = 'unset'
    }
    return () => {
      document.body.style.overflow = 'unset'
    }
  }, [isOpen])

  if (!isOpen) return null

  const sizeClasses = {
    sm: 'max-w-md',
    md: 'max-w-lg',
    lg: 'max-w-2xl',
    xl: 'max-w-4xl',
  }

  return (
    <div className="fixed inset-0 z-[9999] overflow-y-auto" style={{ zIndex: 9999 }}>
      <div className="min-h-screen px-4 text-center">
        {/* Trick para centrar verticalmente */}
        <span className="inline-block h-screen align-middle" aria-hidden="true">
          &#8203;
        </span>

        {/* Overlay con backdrop */}
        <div
          className="fixed inset-0 bg-black bg-opacity-50"
          style={{ zIndex: 9998 }}
          onClick={onClose}
        ></div>

        {/* Modal content */}
        <div
          className={`inline-block w-full ${sizeClasses[size]} my-8 text-left align-middle transition-all transform bg-white shadow-xl rounded-lg`}
          style={{ zIndex: 9999, position: 'relative' }}
        >
          {/* Header */}
          <div className="flex items-center justify-between p-6 border-b bg-white rounded-t-lg">
            <h3 className="text-xl font-semibold text-gray-900">{title}</h3>
            <button
              type="button"
              onClick={onClose}
              className="text-gray-400 hover:text-gray-600 transition-colors"
            >
              <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
              </svg>
            </button>
          </div>

          {/* Body */}
          <div className="p-6 bg-white max-h-[70vh] overflow-y-auto">{children}</div>

          {/* Footer */}
          {footer && <div className="flex items-center justify-end gap-3 p-6 border-t bg-gray-50 rounded-b-lg">{footer}</div>}
        </div>
      </div>
    </div>
  )
}
